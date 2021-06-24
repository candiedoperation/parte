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

public class Parte.Utils.VolatileDataStore : GLib.Object {    
    private Json.Object data_store;
    public signal void display_list_refreshed (Json.Object display_data);
    
    static VolatileDataStore _instance = null;
    public static VolatileDataStore instance {
        get {
            if (_instance == null) {
                _instance = new VolatileDataStore ();
            }
            return _instance;
        }
    }    
    
    public VolatileDataStore () {
        data_store = new Json.Object ();
        data_store.set_object_member ("display-modes", new Json.Object ());
        data_store.set_object_member ("display-nearby", new Json.Object ());
        data_store.set_string_member ("current-display-connection", "");
    }
    
    public void add_display_mode (string mode_name, string mode_id) {
        Json.Object display_modes = data_store.get_object_member ("display-modes");
        display_modes.set_string_member (mode_name, mode_id);
        data_store.set_object_member ("display-modes", display_modes);
        print ("Added New Display Mode: " + mode_name + " (" + mode_id + ")");
    }
    
    public void remove_display_mode (string mode_name) {
        Json.Object display_modes = data_store.get_object_member ("display-modes");
        display_modes.remove_member (mode_name);
        data_store.set_object_member ("display-modes", display_modes);
    }
    
    public string get_display_mode (string mode_name) {
        Json.Object display_modes = data_store.get_object_member ("display-modes");
        return (display_modes.get_string_member (mode_name) == null) ? "" : display_modes.get_string_member (mode_name);
    }
    
    public void add_nearby_display (string IP_Address, string display_uuid, string display_name) {
        Json.Object display_info = new Json.Object ();
        display_info.set_string_member ("display-uuid", display_uuid);
        display_info.set_string_member ("display-name", display_name);

        Json.Object nearby_displays = data_store.get_object_member ("display-nearby");
        nearby_displays.set_object_member (IP_Address, display_info);
        data_store.set_object_member ("display-nearby", nearby_displays);
        
        display_list_refreshed (nearby_displays);
    }
    
    public void remove_nearby_display (string IP_Address) {
        Json.Object nearby_displays = data_store.get_object_member ("display-nearby");
        nearby_displays.remove_member (IP_Address);
        data_store.set_object_member ("display-nearby", nearby_displays);
        
        display_list_refreshed (nearby_displays);        
    }
    
    public string [] get_nearby_display_info (string IP_Address) {
        Json.Object nearby_displays = data_store.get_object_member ("display-nearby");
        if (nearby_displays.get_object_member (IP_Address) == null) { 
            return ({ "" }); 
        } else { 
            return (
                { 
                   IP_Address, 
                   nearby_displays.get_object_member (IP_Address).get_string_member ("display-uuid"), 
                   nearby_displays.get_object_member (IP_Address).get_string_member ("display-name") 
                }
            ); 
        }
    }
    
    public string [] get_nearby_displays () {
        string [] return_nearby_displays = {};
        
        Json.Object nearby_displays = data_store.get_object_member ("display-nearby");
        nearby_displays.get_members ().foreach ((member) => {
            return_nearby_displays += member;
        });
        
        return return_nearby_displays;
    }
    
    public void set_current_connection (string connection) {
        data_store.set_string_member ("current-display-connection", connection);
    }
    
    public string get_busy_state () {
        return data_store.get_string_member ("current-display-connection");
    }
    
    construct {}
}
