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
        
        network_monitor.network_changed.connect ((network_status) => {
            check_network_status (network_status);
        });
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
    
    construct {}
}
