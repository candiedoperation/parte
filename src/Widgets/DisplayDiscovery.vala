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
    private Gtk.ListBox display_list;
    private Granite.Dialog manual_connection_dialog;
    private Parte.Utils.DisplayNetwork display_network;
    private Parte.Utils.VolatileDataStore volatile_data_store;
    private Gtk.Application application;
    private string current_ip;
    private string [] list_array_helper;
    
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
        application = (Gtk.Application) GLib.Application.get_default ();
        display_network = Parte.Utils.DisplayNetwork.instance;
        volatile_data_store = Parte.Utils.VolatileDataStore.instance;
        volatile_data_store.display_list_refreshed.connect ((signal_handler, signal_data) => { update_display_list (signal_data); });
        current_ip = display_network.get_connection_ip (); //UPDATE ON NETWORK CHANGE
        display_network.network_connected.connect (() => { current_ip = display_network.get_connection_ip (); });        
        list_array_helper = {};
                       
        var connection_label = new Gtk.Label ("Available Displays");
        connection_label.hexpand = true;
        connection_label.xalign = (float) 0.0;
        connection_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        
        Gtk.Label help_label = new Gtk.Label ("<a href=''>Unable to Find your Device?</a>");
        help_label.xalign = (float) 1.0;
        help_label.yalign = (float) 1.0;
        help_label.use_markup = true;
        help_label.populate_popup.connect ((popup_menu) => { popup_menu.destroy (); });
        help_label.button_press_event.connect (() => { manual_connection (); });        
        help_label.get_style_context ().add_class (Granite.STYLE_CLASS_ACCENT);
        
        Gtk.Grid label_grid = new Gtk.Grid ();
        label_grid.column_spacing = 5;
        label_grid.attach (connection_label, 0, 0);
        label_grid.attach (help_label, 1, 0);
        
        display_list = new Gtk.ListBox ();
        display_list.hexpand = true;
        display_list.vexpand = true;
        
        display_list.row_activated.connect ((selected_display) => {
            display_network.send_socket_message (list_array_helper [selected_display.get_index ()], ("REQT:" + display_network.get_this_display_beacon ()));
        });
        
        Gtk.ScrolledWindow scrollable_list = new Gtk.ScrolledWindow (null, null);
        scrollable_list.add (display_list);
        scrollable_list.hexpand = true;
        scrollable_list.vexpand = true;        
        
        Gtk.Frame listbox_border = new Gtk.Frame ("");
        listbox_border.get_label_widget ().destroy ();
        listbox_border.hexpand = true;
        listbox_border.vexpand = true;        
        listbox_border.add (scrollable_list);
        
        Gtk.Overlay window_overlay = new Gtk.Overlay ();
        window_overlay.add (listbox_border);
        
        Granite.Widgets.OverlayBar overlaybar = new Granite.Widgets.OverlayBar (window_overlay);
        overlaybar.label = "Discovering Nearby Displays";
        overlaybar.active = true;             
        
        var device_discovery = new Gtk.Grid ();
        device_discovery.hexpand = true;
        device_discovery.vexpand = true;
        device_discovery.row_spacing = 10;
        device_discovery.margin = 10; 
        device_discovery.attach (label_grid, 0, 0);
        device_discovery.attach (window_overlay, 0, 1);
        
        add (device_discovery);
        show_all ();
    }
    
    private void update_display_list (Json.Object nearby_displays) {
        list_array_helper = {};
        display_list.get_children ().foreach ((child) => { child.destroy (); });
        nearby_displays.get_members ().foreach ((display) => {
            if (display != current_ip) {
                display_list.insert (new Parte.Widgets.DisplayPairRow (nearby_displays.get_object_member (display).get_string_member ("display-name")), -1);
                list_array_helper += display;                
            }
        });
    }
    
    private void manual_connection () {
        Gtk.Label IP_Addresss = new Gtk.Label (current_ip);
        IP_Addresss.hexpand = true;
        IP_Addresss.xalign = (float) 0.5;
        IP_Addresss.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);
        
        Gtk.Label info_label = new Gtk.Label ("Enter the above IP Address in the other Computer by Clicking the <b>Connect Manually</b> Button");
        info_label.use_markup = true;
        info_label.wrap = true;
        info_label.width_chars = 40;
        info_label.max_width_chars = 40;
        
        Gtk.Grid top_grid = new Gtk.Grid ();
        top_grid.column_spacing = 10;        
        top_grid.attach (IP_Addresss, 1, 0);        
        
        Gtk.Grid man_info_grid = new Gtk.Grid ();
        man_info_grid.hexpand = true;
        man_info_grid.vexpand = true;
        man_info_grid.row_spacing = 10;
        man_info_grid.margin = 10;
        
        man_info_grid.attach (top_grid, 0, 0);
        man_info_grid.attach (info_label, 0, 1);
        
        manual_connection_dialog.destroy ();
        manual_connection_dialog = new Granite.Dialog ();
        manual_connection_dialog.transient_for = application.active_window;
        manual_connection_dialog.resizable = false;        
        
        manual_connection_dialog.get_content_area ().add (man_info_grid);
        manual_connection_dialog.add_button ("Close", Gtk.ResponseType.CANCEL);
                
        manual_connection_dialog.show_all ();
        manual_connection_dialog.response.connect ((response_id) => {
            manual_connection_dialog.destroy ();
        });        
    }
}
