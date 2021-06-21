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
    private Granite.Dialog manual_connection_dialog;
    private Parte.Utils.DisplayNetwork display_network;
    
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
        display_network = Parte.Utils.DisplayNetwork.instance;
                       
        var connection_label = new Gtk.Label ("Pair a Display");
        connection_label.xalign = (float) 0.0;
        connection_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        
        Gtk.Label help_label = new Gtk.Label ("<a href=''>Unable to Find your Device?</a>");
        help_label.hexpand = true;
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
        
        Gtk.ListBox display_list = new Gtk.ListBox ();
        display_list.hexpand = true;
        display_list.vexpand = true;
        
        Gtk.Frame listbox_border = new Gtk.Frame ("");
        listbox_border.get_label_widget ().destroy ();
        listbox_border.hexpand = true;
        listbox_border.vexpand = true;        
        listbox_border.add (display_list);
        
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
    
    private void manual_connection () {
        Gtk.Label IP_Addresss = new Gtk.Label (display_network.get_connection_ip ());
        IP_Addresss.vexpand = true;
        IP_Addresss.yalign = (float) 0.5;
        IP_Addresss.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);
        
        Gtk.Label info_label = new Gtk.Label ("Enter the above IP Address in the other Computer by Clicking the <b>Connect Manually</b> Button");
        info_label.use_markup = true;
        info_label.wrap = true;
        info_label.max_width_chars = 30;
        
        Gtk.Image dialog_icon = new Gtk.Image ();
        dialog_icon.gicon = new ThemedIcon ("preferences-system-network");
        dialog_icon.pixel_size = 64;
        
        Gtk.Grid top_grid = new Gtk.Grid ();
        top_grid.column_spacing = 10;        
        top_grid.attach (dialog_icon, 0, 0);
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
        manual_connection_dialog.resizable = false;        
        
        manual_connection_dialog.get_content_area ().add (man_info_grid);
        manual_connection_dialog.add_button ("Close", Gtk.ResponseType.CANCEL);
                
        manual_connection_dialog.show_all ();
        manual_connection_dialog.response.connect ((response_id) => {
            manual_connection_dialog.destroy ();
        });        
    }
}
