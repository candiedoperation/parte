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
    private string this_display_beacon;
    public signal void network_connected ();
    public signal void network_disconnected ();
    
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
        volatile_data_store = Parte.Utils.VolatileDataStore.instance;
        
        //Check Network Connection Status and signal Listeners
        network_monitor = NetworkMonitor.get_default ();
        check_network_status (network_monitor.network_available);
        
        //INITIALIZE SOCKET COMMUNICATION CAPABILITIES
        try {
            create_socket_server ();        
        } catch (GLib.Error e) {
            print ("ERR: FAILED TO INITIALIZE COMMUNICATION SOCKET");
            //THROW ERROR TO USER
        }
        
        network_monitor.network_changed.connect ((network_status) => {
            check_network_status (network_status);
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
		broadcast_this_display ();
    }
    
    public void broadcast_this_display () {
        string current_ip = get_connection_ip ();
        Json.Object this_display_info = new Json.Object ();
        this_display_info.set_string_member ("display-uuid", "123456"); //GET DEFINED UUID FROM DB
        this_display_info.set_string_member ("display-name", Environment.get_host_name ()); //GET COMPUTER NAME FROM OS INFO
        
        Json.Object this_display = new Json.Object ();
        this_display.set_object_member (current_ip, this_display_info);
        
        Json.Node this_display_node = new Json.Node (Json.NodeType.OBJECT);
        this_display_node.set_object (this_display);
        
        this_display_beacon = Json.to_string (this_display_node, false);
        string beacon_message = "BEAC:" + this_display_beacon; //No Pretty Printing
        
        int device = 1;
        Thread<void> broadcast_thread = new Thread<void>.try ("broadcast_device_" + device.to_string (), () => { send_device_beacon (device, current_ip.substring (0, current_ip.last_index_of (".") + 1), beacon_message); });
    }    
    
    public void send_device_beacon (int device, string subnet, string beacon_message = "") {
        if (device < 255) {
            print ("BROADCASTING: %s\n", subnet + device.to_string ());
            Thread<void> broadcast_thread = new Thread<void>.try ("broadcast_device_" + (device + 1).to_string (), () => { send_device_beacon ((device + 1), subnet, beacon_message); });            
        }
        
        //IPv4 ITERATOR, THIS IS A SYNCHRONOUS FUNCTION, USE OF Thread<void> RECOMMENDED
        try {
            SocketClient socket_client = new SocketClient ();
            socket_client.timeout = 10; // PULLS ALL THREADS DOWN IN 10 SECONDS
            SocketConnection socket_connection;

            socket_connection = socket_client.connect (new InetSocketAddress (new InetAddress.from_string (subnet + device.to_string ()), 5899));
            socket_connection.output_stream.write (beacon_message.data);            
        } catch (GLib.Error e) {
            print ("NET_DEVICE (%s): %s\n", device.to_string (), e.message);
        } catch (GLib.IOError e) {
            print ("NET_DEVICE (%s): %s\n", device.to_string (), e.message);
        }        
    }
    
    private void send_reply_beacon (string IP_Address) {
        try {
            SocketClient socket_client = new SocketClient ();
            socket_client.timeout = 10;
            SocketConnection socket_connection;

            socket_connection = socket_client.connect (new InetSocketAddress (new InetAddress.from_string (IP_Address), 5899));
            socket_connection.output_stream.write (("ACK_BEAC:" + this_display_beacon).data);            
        } catch (GLib.Error e) {
            print ("NET_DEVICE (%s) ACK_BEAC: %s\n", IP_Address, e.message);
        } catch (GLib.IOError e) {
            print ("NET_DEVICE (%s) ACK_BEAC: %s\n", IP_Address, e.message);
        }        
    }
    
    private async void parse_client_message (SocketConnection connection, Cancellable cancellable) throws GLib.IOError, GLib.Error {
		DataInputStream istream = new DataInputStream (connection.input_stream);
		DataOutputStream ostream = new DataOutputStream (connection.output_stream);		

		// Get the received message:
		string message = yield istream.read_line_async (Priority.DEFAULT, cancellable);
		message._strip ();
		
		if (message.has_prefix ("BEAC:")) {
		    Json.Object display_info = new Json.Object ();
		    display_info = Json.from_string (message.substring (5)).get_object ();
		    display_info.get_members ().foreach ((member) => {
		        volatile_data_store.add_nearby_display (member, display_info.get_object_member (member).get_string_member ("display-uuid"), display_info.get_object_member (member).get_string_member ("display-name"));
                //Thread<void> beacon_reply = new Thread<void>.try ("beacon_reply_" + member, () => { send_reply_beacon (member); });
                ostream.put_string ("ACK_BEAC:" + this_display_beacon);		        
		    });
		} else if (message.has_prefix ("ACK_BEAC:")) {
		    Json.Object display_info = new Json.Object ();
		    display_info = Json.from_string (message.substring (9)).get_object ();
		    display_info.get_members ().foreach ((member) => {
		        volatile_data_store.add_nearby_display (member, display_info.get_object_member (member).get_string_member ("display-uuid"), display_info.get_object_member (member).get_string_member ("display-name"));
		    });		
		} else if (message.has_prefix ("REQT:")) {
		    // GET REQUEST AND USE ACK_REQT TO ACKNOWLEDGE REQUEST AND STRT TO START STREAM
		} else if (message.has_prefix ("BDEL:")) {
		    volatile_data_store.remove_nearby_display (message.substring (5));
		} else if (message.has_prefix ("DISP:")) {

		} else {
		    print (message);
		}
    }
    
    public async void send_socket_message (string IP_Address, string message) {
        
    }
    
    public void close_socket_server () {
        foreach (string display in volatile_data_store.get_nearby_displays ()) {
            try {
                SocketClient socket_client = new SocketClient ();
                socket_client.timeout = 5; // PULLS ALL THREADS DOWN IN 10 SECONDS
                SocketConnection socket_connection;

                socket_connection = socket_client.connect (new InetSocketAddress (new InetAddress.from_string (display), 5899));
                socket_connection.output_stream.write (("BDEL:" + get_connection_ip ()).data);            
            } catch (GLib.Error e) {
                print ("NET_DEVICE (%s): %s\n", display.to_string (), e.message);
            } catch (GLib.IOError e) {
                print ("NET_DEVICE (%s): %s\n", display.to_string (), e.message);
            }            
        };
        
        service.stop ();
    }
    
    public void request_network_check () {
        check_network_status (network_monitor.network_available);
    }
    
    private void check_network_status (bool network_available) {
        if (network_available == false) {
            network_disconnected ();
        } else {
            network_connected ();
        }        
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
        } catch (GLib.Error e) {
            
        }
        
        return auto_ip;        
    }
    
    construct {}
}
