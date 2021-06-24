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

public class Parte.Utils.GTFStandard : GLib.Object {
    private double VERT_FLYBACK;
    private double VERT_SYNC_LINES;
    private double RND_FRONT_PORCH;
    private double CHAR_CELL_GRANL;
    private double DEF_MARG_WIDTH;
    private double HOR_SYNC_WIDTH;
    private double IGN_VERT_MARGIN;
    private double IGN_DISP_INTERLACE;
    private double EST_HOR_PERIOD;
    private double SYNC_BACK_PORCH;
    private double BACK_LINE_PORCH;
    private double VERT_FIELD_LINES;
    private double EST_VERT_FIELD_RATE;
    private double ACT_HOR_PERIOD;
    private double ACT_VERT_FREQ;
    private double ACT_PIXEL_NUM;
    private double IDE_BLANK_DUTY;
    private double DISP_BLANK_TIME;
    private double TOT_LINE_PIXELS;
    private double ACT_HOR_FREQ;
    private double PX_SYNC_WIDTH;
    private double HOR_PORCH_FNT;
    private double HOR_PORCH_BAK;
    
    public double EST_PIXEL_FREQ;
    public double HOR_SYNC_START;
    public double HOR_SYNC_END;
    public double HOR_WID_TOTAL;
    public double VER_SYNC_START;
    public double VER_SYNC_END;
    public double VER_HEIG_TOTAL;
    public string RANDR_MODE_NAME;
    public string PARTE_MODE_NAME;   
    
    public double OPT_HOR_RESOL { get; set; }
    public double OPT_VERT_RESOL { get; set; }
    public double OPT_REFR_RATE { get; set; }
    
    public GTFStandard (double X_RESOL, double Y_RESOL, double SCR_RATE) {        
        //APPLY GTF STANDARDS
        VERT_FLYBACK = 550.000; //Microseconds
        VERT_SYNC_LINES = 3.000; //Lines
        RND_FRONT_PORCH = 1.000; //Units
        CHAR_CELL_GRANL = 8.000; //Units
        DEF_MARG_WIDTH = 1.800; //Percent
        HOR_SYNC_WIDTH = 8.000; //Percent
        IGN_VERT_MARGIN = 0.000; //No Vertical Margin
        IGN_DISP_INTERLACE = 0.000; //No Vertical Interlace
        
        this.notify.connect (() => { if (OPT_HOR_RESOL != 0 && OPT_VERT_RESOL != 0 && OPT_REFR_RATE != 0) { CALC_GTF_STD (); } });        
        
        //APPLY USER SETTINGS
        OPT_HOR_RESOL = (Math.round (X_RESOL / CHAR_CELL_GRANL)) * CHAR_CELL_GRANL;
        OPT_VERT_RESOL = (Math.round (Y_RESOL / CHAR_CELL_GRANL)) * CHAR_CELL_GRANL;
        OPT_REFR_RATE = SCR_RATE;
    }
    
    private void CALC_GTF_STD () {
        EST_HOR_PERIOD = ((1 / OPT_REFR_RATE) - VERT_FLYBACK / 1000000) / (OPT_VERT_RESOL + (2 * IGN_VERT_MARGIN) + RND_FRONT_PORCH + IGN_DISP_INTERLACE) * 1000000;
        SYNC_BACK_PORCH = Math.round (VERT_FLYBACK / EST_HOR_PERIOD); /*ROUNDED TO NEAREST INTEGER*/
        BACK_LINE_PORCH = (SYNC_BACK_PORCH - VERT_SYNC_LINES);
        VERT_FIELD_LINES = (OPT_VERT_RESOL + IGN_VERT_MARGIN + IGN_VERT_MARGIN + SYNC_BACK_PORCH + IGN_DISP_INTERLACE + RND_FRONT_PORCH);
        EST_VERT_FIELD_RATE = 1 / EST_HOR_PERIOD / VERT_FIELD_LINES * 1000000;
        ACT_HOR_PERIOD = EST_HOR_PERIOD / (OPT_REFR_RATE / EST_VERT_FIELD_RATE);
        ACT_VERT_FREQ = 1 / ACT_HOR_PERIOD / VERT_FIELD_LINES * 1000000;
        ACT_PIXEL_NUM = OPT_HOR_RESOL; //ADDITION OF HORIZONTAL MARGINS ARE EXEMPTED
        
        /*
            Apply Blanking Time Formula with default Values:
                M (Gradient) = 600
                C (Offset) = 40
                K (Blank Time Scale Factor) = 128
                J (Scaling Factor Weighting) = 20
                Blanking Time Formula = C - ( M / Fh ) 
        */
        
        IDE_BLANK_DUTY = (((40 - 20) * 128 / 256) + 20) - ((300) * ACT_HOR_PERIOD / 1000);
        
        DISP_BLANK_TIME = Math.round ((ACT_PIXEL_NUM * IDE_BLANK_DUTY / (100 - IDE_BLANK_DUTY) / (2 * CHAR_CELL_GRANL))) * (2 * CHAR_CELL_GRANL); /*ROUNDED OF TO NEAREST CHAR_CELL_GRANL*/
        TOT_LINE_PIXELS = (ACT_PIXEL_NUM + DISP_BLANK_TIME);
        EST_PIXEL_FREQ = (TOT_LINE_PIXELS / ACT_HOR_PERIOD);  
        ACT_HOR_FREQ = (1000 / ACT_HOR_PERIOD);
        
        PX_SYNC_WIDTH = Math.round ((HOR_SYNC_WIDTH / 100 * TOT_LINE_PIXELS / CHAR_CELL_GRANL)) * CHAR_CELL_GRANL; /*ROUNDED OF TO NEAREST CHAR_CELL_GRANL*/
        HOR_PORCH_FNT = (DISP_BLANK_TIME / 2) - PX_SYNC_WIDTH;
        HOR_PORCH_BAK = HOR_PORCH_FNT + PX_SYNC_WIDTH;
        
        HOR_SYNC_START = OPT_HOR_RESOL + HOR_PORCH_FNT;
        HOR_SYNC_END = HOR_SYNC_START + PX_SYNC_WIDTH;
        HOR_WID_TOTAL = HOR_SYNC_END + HOR_PORCH_BAK;
        
        VER_SYNC_START = OPT_VERT_RESOL + RND_FRONT_PORCH;
        VER_SYNC_END = VER_SYNC_START + VERT_SYNC_LINES;
        VER_HEIG_TOTAL = VER_SYNC_END + BACK_LINE_PORCH;        
        
        RANDR_MODE_NAME = (OPT_HOR_RESOL.to_string ()) + "x" + (OPT_VERT_RESOL.to_string ()) + "_" + (OPT_REFR_RATE.to_string ());
        if (OPT_REFR_RATE % 1 == 0) { RANDR_MODE_NAME += ".00"; }
        
        PARTE_MODE_NAME = "PARTE_" + RANDR_MODE_NAME;
    }
    
    public string GET_MODELINE () {
        return "Modeline \"" + RANDR_MODE_NAME + "\"  " + (EST_PIXEL_FREQ.to_string ()) + "  " + (OPT_HOR_RESOL.to_string ()) + " " + (HOR_SYNC_START.to_string ()) + " " + (HOR_SYNC_END.to_string ()) + " " + (HOR_WID_TOTAL.to_string ()) + "  " + (OPT_VERT_RESOL.to_string ()) + " " + (VER_SYNC_START.to_string ()) + " " + (VER_SYNC_END.to_string ()) + " " + (VER_HEIG_TOTAL.to_string ()) + "  " + "-HSync +Vsync\n";
    }
    
    public string GET_VIRT_DISPLAY_LABEL (double client_width, double client_height, double server_width) {
        return ("%sx%s+%s+0".printf (client_width.to_string (), client_height.to_string (), server_width.to_string ()));
    }
    
    construct {}
}
