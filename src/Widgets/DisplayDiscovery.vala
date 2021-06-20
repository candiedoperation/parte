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

public class Parte.Widgets.DisplayDiscovery : Gtk.Grid {
    static DisplayDiscovery _instance = null;
    public static DisplayDiscovery instance {
        get {
            if (_instance == null) {
                _instance = new DisplayDiscovery ();
            }
            return _instance;
        }
    }
                    
    public DisplayDiscovery () {
                         
    }
    
    construct {
        var connection_label = new Gtk.Label ("Pair a Display");
        connection_label.xalign = (float) 0.0;
        connection_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        
        Gtk.ListBox display_list = new Gtk.ListBox ();
        display_list.hexpand = true;
        display_list.vexpand = true;
        
        Gtk.Frame listbox_border = new Gtk.Frame ("");
        listbox_border.get_label_widget ().destroy ();
        listbox_border.hexpand = true;
        listbox_border.vexpand = true;        
        listbox_border.add (display_list);
        
        var device_discovery = new Gtk.Grid ();
        device_discovery.hexpand = true;
        device_discovery.vexpand = true;
        device_discovery.row_spacing = 10;
        device_discovery.margin = 10; 
        device_discovery.attach (connection_label, 0, 0);
        device_discovery.attach (listbox_border, 0, 1);        
        
        add (device_discovery);
        show_all ();        
    }
    
    public void start_discovery () {
        //var a = new Parte.Widgets.DisplayPairRow ("");
        //display_list.insert (a, -1);
        
    }
}
