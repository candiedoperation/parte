/*
    Parte
    Copyright (C) 2021  Atheesh Thirumalairajan

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    
    Authored By: Atheesh Thirumalairajan <candiedoperation@icloud.com>
*/

public class Parte.Utils.DisplayNetwork : GLib.Object {
    private NetworkMonitor network_monitor;
    private GLib.SocketService service;
    private Parte.Utils.VolatileDataStore volatile_data_store;
    private Parte.Utils.VirtualDisplayEnvironment virtual_display;
    private Gtk.Application application;
    private string this_display_beacon;
    private string current_ip;
    private string current_subnet;
    public signal void network_connected ();
    public signal void network_disconnected ();
    public signal void request_app_notification (GLib.Notification notification);
    
    static DisplayNetwork _instance = null;
    public static DisplayNetwork instance {
        get {
            if (_instance == null) {
                _instance = new DisplayNetwork ();
            }
            return _instance;
        }
    }
    
    public DisplayNetwork () {
        application = (Gtk.Application) GLib.Application.get_default ();
        volatile_data_store = Parte.Utils.VolatileDataStore.instance;
        virtual_display = Parte.Utils.VirtualDisplayEnvironment.instance;
        current_ip = "192.168.30.217"; //CHANGE AT LAST
        current_subnet = current_ip.substring (0, current_ip.last_index_of (".") + 1);
        
        //Check Network Connection Status and signal Listeners
        network_monitor = NetworkMonitor.get_default ();
        
        if (network_monitor.network_available == true) {
            current_ip = get_connection_ip ();
            current_subnet = current_ip.substring (0, current_ip.last_index_of (".") + 1);
            broadcast_this_display ();            
        }        
        
        try {
            create_socket_server ();        
        } catch (GLib.Error e) {
            print ("ERR: FAILED TO INITIALIZE COMMUNICATION SOCKET");
        }
        
        network_monitor.network_changed.connect ((network_status) => {
            if (network_status == true && network_monitor.network_available == false) {
                network_disconnected ();
            } else if (network_status == true && network_monitor.network_available == true && get_connection_ip () != "") {
                print ("New IP: %s, NETSTAT: %s\n", get_connection_ip (), network_status.to_string ());
                current_ip = get_connection_ip ();
                current_subnet = current_ip.substring (0, current_ip.last_index_of (".") + 1);
                broadcast_this_display ();                
                network_connected ();
            } else {
                network_disconnected ();
            }
        });
    }
    
    public void create_socket_server () throws GLib.Error {
		service = new GLib.SocketService ();
		service.add_inet_port (5899, this);
		service.incoming.connect ((connection, source_object) => {
		    parse_client_message (connection, new Cancellable ());
		    return false;
		});

		service.start ();
    }
    
    public void broadcast_this_display () {
        Json.Object this_display_info = new Json.Object ();
        this_display_info.set_string_member ("display-uuid", "123456"); //GET DEFINED UUID FROM DB
        this_display_info.set_string_member ("display-name", Environment.get_host_name ()); //GET COMPUTER NAME FROM OS INFO
        
        Json.Object this_display = new Json.Object ();
        this_display.set_object_member (current_ip, this_display_info);
        
        Json.Node this_display_node = new Json.Node (Json.NodeType.OBJECT);
        this_display_node.set_object (this_display);
        
        this_display_beacon = Json.to_string (this_display_node, false);
        string beacon_message = "BEAC:" + this_display_beacon; //No Pretty Printing
        
        Thread<void> broadcast_thread = new Thread<void>.try ("broadcast_device_1", () => { send_device_beacon (1, beacon_message); });
    }    
    
    public void send_device_beacon (int device, string beacon_message = "") {
        //IPv4 ITERATOR, THIS IS A SYNCHRONOUS FUNCTION, USE OF Thread<void> RECOMMENDED            
        if (network_monitor.network_available == true && current_ip != "") {
            if (device < 255) {
                print ("BROADCASTING: %s\n", current_subnet + device.to_string ());
                Thread<void> broadcast_thread = new Thread<void>.try ("broadcast_device_" + (device + 1).to_string (), () => { send_device_beacon ((device + 1), beacon_message); });            
            }

            try {
                SocketClient socket_client = new SocketClient ();
                socket_client.timeout = 10; // PULLS ALL THREADS DOWN IN 10 SECONDS
                SocketConnection socket_connection;

                socket_connection = socket_client.connect (new InetSocketAddress (new InetAddress.from_string (current_subnet + device.to_string ()), 5899));
                socket_connection.output_stream.write (beacon_message.data);            
            } catch (GLib.Error e) {
                print ("NET_DEVICE (%s): %s\n", device.to_string (), e.message);
            } catch (GLib.IOError e) {
                print ("NET_DEVICE (%s): %s\n", device.to_string (), e.message);
            }            
        }
    }
    
    private void reply_device_beacon (string IP_Address, string beacon_msg) {
        try {
            SocketClient socket_client = new SocketClient ();
            socket_client.timeout = 10;
            SocketConnection socket_connection;

            socket_connection = socket_client.connect (new InetSocketAddress (new InetAddress.from_string (IP_Address), 5899));
            socket_connection.output_stream.write (beacon_msg.data);            
        } catch (GLib.Error e) {
            print ("NET_DEVICE (%s) SEND_MSG: %s\n", IP_Address, e.message);
        } catch (GLib.IOError e) {
            print ("NET_DEVICE (%s) SEND_MSG: %s\n", IP_Address, e.message);
        }        
    }
    
    private async void parse_client_message (SocketConnection connection, Cancellable cancellable) throws GLib.IOError, GLib.Error {
		DataInputStream istream = new DataInputStream (connection.input_stream);

		string message = yield istream.read_line_async (Priority.DEFAULT, cancellable);
		message._strip ();

		if (message.has_prefix ("BEAC:")) { received_beacon (message); }
        else if (message.has_prefix ("ACK_BEAC:")) { acknowledge_received_beacon (message); }
		else if (message.has_prefix ("REQT:")) { receive_connection_request (message); }
		else if (message.has_prefix ("ACK_REQT:")) { on_connection_permitted (message); }
		else if (message.has_prefix ("GET_DISP:")) { init_virtual_env (message); }
		else if (message.has_prefix ("BDEL:")) { volatile_data_store.remove_nearby_display (message.substring (5)); } 
		else if (message.has_prefix ("DISP:")) {} 
		else { print ("Probable External Source: " + message); }
    }

    private void received_beacon (string message) {
        Json.Object display_info = new Json.Object ();
        display_info = Json.from_string (message.substring (5)).get_object ();
        display_info.get_members ().foreach ((member) => {
            volatile_data_store.add_nearby_display (member, display_info.get_object_member (member).get_string_member ("display-uuid"), display_info.get_object_member (member).get_string_member ("display-name"));
            Thread<void> beacon_reply = new Thread<void>.try ("beacon_reply_" + member, () => { reply_device_beacon (member, ("ACK_BEAC:" + this_display_beacon)); });		        
        });
    }

    private void acknowledge_received_beacon (string message) {
        Json.Object display_info = new Json.Object ();
        display_info = Json.from_string (message.substring (9)).get_object ();
        display_info.get_members ().foreach ((member) => {
            volatile_data_store.add_nearby_display (member, display_info.get_object_member (member).get_string_member ("display-uuid"), display_info.get_object_member (member).get_string_member ("display-name"));
        });
    }

    private void receive_connection_request (string message) {
        Json.Object display_info = new Json.Object ();
        display_info = Json.from_string (message.substring (5)).get_object ();        
        if (check_pairing_status (display_info.get_object_member (display_info.get_members ().nth_data (0)).get_string_member ("display-uuid")) == true) {
            //PROCEED CONNECTION WITHOUT CONFIRMATION
        } else {
            GLib.SimpleAction allow_once = new GLib.SimpleAction ("allow-connect-once", null);
            allow_once.activate.connect (() => { connection_permitted (message); });

            GLib.SimpleAction allow_pair = new GLib.SimpleAction ("allow-connect-pair", null);
            allow_pair.activate.connect (() => { pair_device (display_info.get_object_member (display_info.get_members ().nth_data (0)).get_string_member ("display-uuid")); connection_permitted (message); });
            
            application.add_action (allow_once);
            application.add_action (allow_pair);            

            GLib.Notification request_notification = new GLib.Notification ("display-requested");
            request_notification.set_title ("Display Connection Request");
            request_notification.set_body (display_info.get_object_member (display_info.get_members ().nth_data (0)).get_string_member ("display-name").substring (0, 15) + "… wants to use this computer's display as a second screen.");
            request_notification.set_icon (new ThemedIcon ("network-wired"));
            request_notification.add_button ("Pair and Allow", "app.allow-connect-pair");
            request_notification.add_button ("Allow", "app.allow-connect-once");
            request_notification.set_priority (GLib.NotificationPriority.URGENT);

            application.send_notification ("display_network", request_notification);
        }
    }

    public void connection_permitted (string message) {
        Json.Object display_info = new Json.Object ();
        display_info = Json.from_string (message.substring (5)).get_object ();
        application.withdraw_notification ("display_network");
        
        string member = display_info.get_members ().nth_data (0);
        volatile_data_store.set_current_connection (member);
        Thread<void> beacon_reply = new Thread<void>.try ("connection_reply_" + member, () => { reply_device_beacon (member, ("ACK_REQT:" + this_display_beacon)); });        
    }
    
    private void on_connection_permitted (string message) {
        //SHOW CONNECTING SPINNER
        Json.Object display_info = new Json.Object ();
        display_info = Json.from_string (message.substring (9)).get_object ();
        string member = display_info.get_members ().nth_data (0);
        volatile_data_store.set_current_connection (member);
        
        Json.Object this_display_config = virtual_display.get_primary_monitor ();
        display_info.set_object_member ("m-data", this_display_config);
        
        Json.Node this_display_node = new Json.Node (Json.NodeType.OBJECT);
        this_display_node.set_object (display_info);
        
        Thread<void> broadcast_thread = new Thread<void>.try ("reply_connection_reply_" + member, () => { reply_device_beacon (member, "GET_DISP:" + Json.to_string (this_display_node, false)); });        
    }
    
    private void init_virtual_env (string message) {
        print (message);
    }    

    public void close_socket_server () {
        foreach (string display in volatile_data_store.get_nearby_displays ()) {
            try {
                SocketClient socket_client = new SocketClient ();
                socket_client.timeout = 5; // PULLS ALL THREADS DOWN IN 10 SECONDS
                SocketConnection socket_connection;

                socket_connection = socket_client.connect (new InetSocketAddress (new InetAddress.from_string (display), 5899));
                socket_connection.output_stream.write (("BDEL:" + current_ip).data);            
            } catch (GLib.Error e) {
                print ("NET_DEVICE (%s): %s\n", display.to_string (), e.message);
            } catch (GLib.IOError e) {
                print ("NET_DEVICE (%s): %s\n", display.to_string (), e.message);
            }            
        };

        service.stop ();
    }

    public void request_network_check () {
        if (network_monitor.network_available == true) {
            network_connected ();
        } else {
            network_disconnected ();
        }
    }
    
    private bool check_pairing_status (string display_uuid) {
        return false;
    }
    
    private void pair_device (string display_uuid) {
        
    }    

    public string get_connection_ip () {
        string auto_ip = "";
        try {
            NM.Client nm_client = new NM.Client ();
            nm_client.get_devices ().foreach((device) => {
                device.get_ip4_config ().get_addresses ().foreach((ip_addr) => {
                    GLib.InetAddress current_ip = new GLib.InetAddress.from_string (ip_addr.get_address ());
                    if (current_ip.is_loopback == false) {
                        print (ip_addr.get_address () + "\n");
                        (auto_ip != "") ? auto_ip = auto_ip : auto_ip = ip_addr.get_address ();                    
                    }
                });
            });            
        } catch (GLib.Error e) {}

        //Returning the Preffered IP Address
        return auto_ip;        
    }
    
    public string get_this_display_beacon () {
        return this_display_beacon;
    }
    
    public void send_socket_message (string IP_Address, string message) {
        reply_device_beacon (IP_Address, message);
    }

    construct {}
}
