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
    private Gtk.Grid grid_main;
    private Gtk.Grid hdy_grid;
    private Hdy.HeaderBar hdy_header;
    public signal void hide_application (); 

    public MainWindow () {
        Object (
            resizable: true,
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
        
        var virt_display_view = new Parte.Utils.VirtualDisplayViewer ("192.168.30.47", "5900");
        var vde = new Parte.Utils.VirtualDisplayEnvironment ();
        vde.create_environment (1920, 1080, 60);        
        
        grid_main = new Gtk.Grid();
        grid_main.attach (virt_display_view, 0, 0);
        
        hdy_header = new Hdy.HeaderBar ();
        hdy_header.title = "Parte";
        hdy_header.hexpand = true;
        hdy_header.show_close_button = true;
        hdy_header.decoration_layout = "close:";       
        
        hdy_grid = new Gtk.Grid ();
        hdy_grid.attach (hdy_header, 0, 0);
        hdy_grid.attach (grid_main, 0, 1);
        
        virt_display_view.hide_application.connect(() => { hide_application(); });
        
        virt_display_view.request_fullscreen.connect(() => {
            this.fullscreen ();
            hdy_grid.remove (hdy_header);            
        });
        
        virt_display_view.request_unfullscreen.connect(() => {
            this.unfullscreen ();
            hdy_grid.attach (hdy_header, 0, 0);            
        });                 
        
        add(hdy_grid);
        show_all();
    }
}

