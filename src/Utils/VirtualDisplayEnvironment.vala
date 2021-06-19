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

public class Parte.Utils.VirtualDisplayEnvironment : GLib.Object {
    private Parte.Utils.GTFStandard gtime_f;
    private Parte.Utils.VolatileDataStore volatile_data_store;
    private Xcb.RandR.GetScreenResourcesReply screen_resources; 
    private Xcb.RandR.Connection xcb_randr_connection;
    private Xcb.Window virt_display_window;
    private Xcb.Connection xcb_connection;
    
    static VirtualDisplayEnvironment _instance = null;
    public static VirtualDisplayEnvironment instance {
        get {
            if (_instance == null) {
                _instance = new VirtualDisplayEnvironment ();
            }
            return _instance;
        }
    }        
        
    public VirtualDisplayEnvironment () {
        volatile_data_store = Parte.Utils.VolatileDataStore.instance;
                    
        xcb_connection = new Xcb.Connection (); //Connect to X Window System
        xcb_randr_connection = Xcb.RandR.get_connection (xcb_connection); //Create an Xcb.RandR Connection        
        Xcb.Setup xcb_setup = xcb_connection.get_setup (); //Get XCB Setup
        Xcb.ScreenIterator xcb_screen_iterator = xcb_setup.roots_iterator (); //Iterate available Screens
        Xcb.Screen xcb_screen = xcb_screen_iterator.data; //Get the first Screen
        
        virt_display_window = xcb_connection.generate_id ();       
        xcb_connection.create_window (
            Xcb.COPY_FROM_PARENT, // Copy Window Depth from Parent Window
            virt_display_window, // Use the newly created window
            xcb_screen.root, // Use root window as the Parent Window
            0, 0, // X, Y coords
            1, 1, // End X, Y coords (Lower than 1 fails creation)
            0, // Window Border Width
            Xcb.WindowClass.INPUT_OUTPUT, // Add Window Class
            xcb_screen.root_visual, // Set VisualID same as the first screen
            0, // Window Masks
            {} // Window Masks
        );
        
        xcb_connection.flush ();
        
        screen_resources = xcb_randr_connection.get_screen_resources_reply (xcb_randr_connection.get_screen_resources (virt_display_window));
        update_volatile_db ();        
    }
    
    public void create_environment (double display_width, double display_height, double display_frequency) {
        gtime_f = new Parte.Utils.GTFStandard (display_width, display_height, display_frequency);
                    
        if (volatile_data_store.get_display_mode (gtime_f.PARTE_MODE_NAME) == "") {
            screen_resources = xcb_randr_connection.get_screen_resources_reply (xcb_randr_connection.get_screen_resources (virt_display_window));
            foreach (Xcb.RandR.Output output in screen_resources.outputs) {
                Xcb.RandR.GetOutputInfoReply output_info = xcb_randr_connection.get_output_info_reply (xcb_randr_connection.get_output_info (output, screen_resources.config_timestamp));
                if (output_info.name.up () == "VIRTUAL1") {
                    xcb_randr_connection.add_output_mode (output, create_display_mode ());
                    update_volatile_db ();                                         
                    add_display_mode ();                                                        
                    break;
                }
            }
        }
    }    
    
    private Xcb.RandR.Mode create_display_mode () {
        Xcb.RandR.ModeInfo virt_display_modeline = Xcb.RandR.ModeInfo () {
            dot_clock = (uint32) (gtime_f.EST_PIXEL_FREQ * 1e6), //dot_clock expects Hz (uint32 is 10 digits long) and not MHz as calculated in GTFStandard.vala
            width = (uint16) gtime_f.OPT_HOR_RESOL,
            hsync_start = (uint16) gtime_f.HOR_SYNC_START,
            hsync_end = (uint16) gtime_f.HOR_SYNC_END,
            htotal = (uint16) gtime_f.HOR_WID_TOTAL,
            hskew = (uint16) 0,
            height = (uint16) gtime_f.OPT_VERT_RESOL,
            vsync_start = (uint16) gtime_f.VER_SYNC_START,
            vsync_end = (uint16) gtime_f.VER_SYNC_END,
            vtotal = (uint16) gtime_f.VER_HEIG_TOTAL,
            mode_flags = Xcb.RandR.ModeFlag.HSYNC_NEGATIVE + Xcb.RandR.ModeFlag.VSYNC_POSITIVE,
            name_len = (uint16) gtime_f.PARTE_MODE_NAME.length          
        };
        
        Xcb.RandR.CreateModeReply virt_display_mode_reply = xcb_randr_connection.create_mode_reply (xcb_randr_connection.create_mode (virt_display_window, virt_display_modeline, gtime_f.PARTE_MODE_NAME)); // Get the created mode from CreateModeReply
        return virt_display_mode_reply.mode;                
    }
    
    public void reset_display_modes () {
        foreach (Xcb.RandR.Output output in screen_resources.outputs) {
            Xcb.RandR.GetOutputInfoReply output_info = xcb_randr_connection.get_output_info_reply (xcb_randr_connection.get_output_info (output, screen_resources.config_timestamp));          
            if (output_info.name.up () == "VIRTUAL1") {
                foreach (Xcb.RandR.Mode mode in output_info.modes) {                  
                    xcb_randr_connection.delete_output_mode (output, mode);
                    xcb_randr_connection.destroy_mode (mode);
                }
                
                //Destroyed All Modes
                break;                
            }
        }        
    }
    
    public void add_display_mode () {
        screen_resources = xcb_randr_connection.get_screen_resources_reply (xcb_randr_connection.get_screen_resources (virt_display_window));    
        foreach (Xcb.RandR.Output output in screen_resources.outputs) {
            Xcb.RandR.GetOutputInfoReply output_info = xcb_randr_connection.get_output_info_reply (xcb_randr_connection.get_output_info (output, screen_resources.config_timestamp));          
            if (output_info.name.up () == "VIRTUAL1") {
                foreach (Xcb.RandR.Mode mode in output_info.modes) {
                    print ("ADDING OUTPUT MODES\n");                   
                    xcb_randr_connection.add_output_mode (output, mode);
                    xcb_randr_connection.destroy_mode (mode);
                }
                
                //COMPLETED ADDING ALL MODES TO VIRTUAL1
                break;                
            }
        }        
    }
    
    private void update_volatile_db () {
        for (int iterator = 0; iterator < screen_resources.mode_names.length; iterator++) {
            if (screen_resources.mode_names [iterator].has_prefix ("PARTE_")) {
                volatile_data_store.add_display_mode (screen_resources.mode_names [iterator], screen_resources.modes [iterator].id.to_string ());
            }            
        }
    }   
    
    construct {
        //Ask Graphic Card to create Virtual Display `nano /usr/share/X11/xorg.conf.d/20-intel.conf`
    }
}
