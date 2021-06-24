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

public class Parte.Widgets.DisplayConnected : Gtk.Grid {
    public string display_name { get; set; }
                
    public DisplayConnected () {}
    
    construct {
        display_name = "VIRTUAL DISPLAY 01";
        
        Gtk.Label connected_label_static = new Gtk.Label ("Display Connected");
        connected_label_static.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);
        
        Gtk.Image display_logo = new Gtk.Image ();
        display_logo.gicon = new ThemedIcon ("video-display");
        display_logo.pixel_size = 128;
        
        Gtk.Label connection_label = new Gtk.Label (display_name);
        connection_label.ellipsize = Pango.EllipsizeMode.START;
        connection_label.hexpand = true;
        connection_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        
        Gtk.Grid labels_grid = new Gtk.Grid ();
        labels_grid.vexpand = true;
        labels_grid.valign = Gtk.Align.CENTER;
        labels_grid.attach (connected_label_static, 0, 0);
        labels_grid.attach (connection_label, 0, 1);        
        
        Gtk.Grid connection_static = new Gtk.Grid ();
        connection_static.column_spacing = 15;
        connection_static.attach (display_logo, 0, 0);
        connection_static.attach (labels_grid, 1, 0);
        
        this.notify.connect (() => {
            connection_label.label = display_name;
        });
        
        Gtk.Grid connection_status = new Gtk.Grid ();
        connection_status.hexpand = true;
        connection_status.vexpand = true;
        connection_status.halign = Gtk.Align.CENTER;
        connection_status.valign = Gtk.Align.CENTER;
        connection_status.attach (connection_static, 0, 0);
        //connection_status.attach (connection_dynamic, 0, 1);
        
        add (connection_status);
        show_all ();        
    }
}
