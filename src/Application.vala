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

public class Parte.App : Gtk.Application {
    construct {
        application_id = "com.github.candiedoperation.parte";
        flags = ApplicationFlags.FLAGS_NONE;
    }

    public override void activate () {
        Hdy.init (); //Initializing LibHandy
        Parte.Utils.VirtualDisplayEnvironment virtual_display = Parte.Utils.VirtualDisplayEnvironment.instance; //Initializing Virtual Display Module
        
        var window = new Parte.MainWindow ();
        window.application = this;
        window.window_position = Gtk.WindowPosition.CENTER;
        window.show_all ();
        
        window.hide_application.connect(() => {
            this.hold ();
            window.hide ();
        });
        
        window.delete_event.connect(() => {            
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                "Close Parte?",
                "Closing Parte will disconnect all external monitors and prevent this monitor from being discovered.",
                "dialog-warning",
                Gtk.ButtonsType.NONE                
            );
            
            message_dialog.transient_for = window;

            var close_app_button = new Gtk.Button.with_label ("Close Parte");
            close_app_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            message_dialog.add_action_widget (close_app_button, Gtk.ResponseType.ACCEPT);
            
            var hide_app_button = new Gtk.Button.with_label ("Run In Background");
            hide_app_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            message_dialog.add_action_widget (hide_app_button, Gtk.ResponseType.CLOSE);            

            message_dialog.show_all ();
            message_dialog.response.connect ((response_id) => {
                if (response_id == Gtk.ResponseType.ACCEPT) {
                    virtual_display.reset_display_modes (); //GLITCHES IN THE FUNCTION
                    this.quit ();
                } else if (response_id == Gtk.ResponseType.CLOSE) {
                    this.hold ();
                    window.hide ();                    
                } 
                
                message_dialog.destroy ();
            });
            
            return true;                        
        });
    }
}

public static int main (string[] args) {
    var application = new Parte.App ();
    return application.run (args);
}
