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
        display_modes.set_object_member ("display-modes", display_modes);
    }
    
    public string get_display_mode (string mode_name) {
        Json.Object display_modes = data_store.get_object_member ("display-modes");
        return (display_modes.get_string_member (mode_name) == null) ? "" : display_modes.get_string_member (mode_name);
    }
    
    construct {}
}
