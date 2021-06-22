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
    private string [] 
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
        //Check Network Connection Status and signal Listeners
        network_monitor = NetworkMonitor.get_default ();
        check_network_status (network_monitor.network_available);
        
        //INITIALIZE SOCKET COMMUNICATION CAPABILITIES
        try {
            create_socket_server ();        
        } catch (GLib.Error e) {
            
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
    }
    
    public void send_socket_message () {
        
    }
    
    private async void parse_client_message (SocketConnection connection, Cancellable cancellable) throws GLib.IOError {
		DataInputStream istream = new DataInputStream (connection.input_stream);

		// Get the received message:
		string message = yield istream.read_line_async (Priority.DEFAULT, cancellable);
		message._strip ();
		
		if (message.has_prefix ("DISC:")) {
		    //SECONDARY DISPLAY DISCOVERY
		} else if (message.has_prefix ("REQT:")) {
		    //CHK PAIRED DEVICE LIST
		} else if (message.has_prefix ("DISP:")) {
		    //SECONDARY DISPLAY INFORMATION
		} else {
		    //MESSAGE REJECTED
		}
    }
    
    public void close_socket_server () {
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
