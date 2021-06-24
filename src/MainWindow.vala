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

public class Parte.MainWindow : Hdy.ApplicationWindow {
    //private static GLib.Settings settings;
    private Gtk.Grid hdy_grid;   
    private Gtk.Button back_button;
    private Hdy.HeaderBar hdy_header;
    private Hdy.Carousel main_carousel;
    private Parte.Utils.VirtualDisplayViewer display_viewer;
    private Parte.Widgets.DisplayDiscovery display_finder;
    private Parte.Utils.DisplayNetwork display_network;
    public signal void hide_application (); 

    public MainWindow () {
        Object (
            resizable: false,
            title: "Parte",
            window_position: Gtk.WindowPosition.CENTER,
            width_request: 860,
            height_request: 660
        );
    }

    construct {        
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
        
        display_network = Parte.Utils.DisplayNetwork.instance;
        display_network.view_display_stream.connect ((signal_handler, IP_Address) => { view_display_stream (IP_Address); });
        display_viewer = new Parte.Utils.VirtualDisplayViewer ();
        
        Granite.Widgets.Welcome welcome_parte = new Granite.Widgets.Welcome ("Parte", "Extend Displays, Seamlessly.");
        welcome_parte.hexpand = true;
        welcome_parte.vexpand = true;
        welcome_parte.append ("preferences-system-sharing", "Extend My Display", "Extend this display to some other Parte Display.");
        welcome_parte.append ("video-display", "Use this as Secondary Display", "Use this as a secondary display for another computer.");
        welcome_parte.append ("emblem-synchronized", "View Paired Displays", "View Displays which are paired to this Computer.");        
        welcome_parte.append ("preferences-system", "Preferences", "View and Modify Parte Settings.");          
        
        display_finder = Parte.Widgets.DisplayDiscovery.instance;
        
        main_carousel = new Hdy.Carousel ();
        main_carousel.hexpand = true;
        main_carousel.vexpand = true;
        main_carousel.interactive = false;
        
        main_carousel.insert (welcome_parte, -1);
        main_carousel.insert (display_finder, -1);
        
        Gtk.Image network_alert = new Gtk.Image ();
        network_alert.gicon = new ThemedIcon ("network-wired-disconnected");
        network_alert.pixel_size = 28;
        network_alert.set_tooltip_text ("Network Disconnected");               
        
        hdy_header = new Hdy.HeaderBar ();
        hdy_header.title = "Parte";
        hdy_header.hexpand = true;
        hdy_header.pack_end (network_alert);        
        hdy_header.show_close_button = true;
        hdy_header.decoration_layout = "close:";                       
        
        hdy_grid = new Gtk.Grid ();
        hdy_grid.attach (hdy_header, 0, 0);
        hdy_grid.attach (main_carousel, 0, 1);
        
        display_network.network_disconnected.connect (() => {
            welcome_parte.get_button_from_index (0).sensitive = false;
            welcome_parte.get_button_from_index (1).sensitive = false;
            main_carousel.scroll_to (welcome_parte);
            hdy_header.pack_end (network_alert);            
        });
        
        display_network.network_connected.connect (() => {
            welcome_parte.get_button_from_index (0).sensitive = true;
            welcome_parte.get_button_from_index (1).sensitive = true;
            hdy_header.remove (network_alert);            
        });        
        
        welcome_parte.activated.connect ((select_index) => {
            switch (select_index) {
                case 0: {
                    main_carousel.scroll_to (display_finder);
                    break;                    
                }
            }
        });
        
        main_carousel.page_changed.connect ((current_page) => {
            switch (current_page) {
                case 1: {
                    back_button.destroy ();
                    
                    back_button = new Gtk.Button ();
                    back_button.label = "Home";
                    back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);
                    
                    back_button.clicked.connect (() => {
                        main_carousel.scroll_to (welcome_parte);
                        back_button.destroy ();
                    });
                                     
                    hdy_header.pack_start (back_button);
                    show_all ();                    
                }
            }
        });
        
        display_viewer.hide_application.connect(() => {
            hide_application();
        });
        
        display_viewer.request_fullscreen.connect(() => {
            this.fullscreen ();
            hdy_grid.remove (hdy_header);            
        });
        
        display_viewer.request_unfullscreen.connect(() => {
            this.unfullscreen ();
            hdy_grid.attach (hdy_header, 0, 0);            
        });                 
        
        add(hdy_grid);
        show_all();
                
        display_network.request_network_check ();        
    }
    
    private void view_display_stream (string IP_Address) {
        display_viewer.IP_Address = IP_Address;
        main_carousel.insert (display_viewer, -1);
    }    
}

