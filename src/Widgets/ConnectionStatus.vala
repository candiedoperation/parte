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

public class Parte.Widgets.ConnectionStatus : Gtk.Grid {
    public Gtk.Spinner connection_spinner;
                
    public ConnectionStatus () {
                         
    }
    
    construct {
        connection_spinner = new Gtk.Spinner ();
        connection_spinner.width_request = 48;
        connection_spinner.height_request = 48;
        
        var connection_label = new Gtk.Label ("Connecting to Display");
        connection_label.hexpand = true;
        connection_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);
        
        var connection_progress = new Gtk.Grid ();
        connection_progress.hexpand = true;
        connection_progress.vexpand = true;
        connection_progress.halign = Gtk.Align.CENTER;
        connection_progress.valign = Gtk.Align.CENTER;
        connection_progress.attach (connection_spinner, 0, 0);
        connection_progress.attach (connection_label, 0, 1);
        
        add (connection_progress);
        show_all ();        
    }
}
