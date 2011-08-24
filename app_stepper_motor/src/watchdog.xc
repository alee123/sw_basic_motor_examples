// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
                             
#include "watchdog.h"
#include <xs1.h>

/* handle all watchdog functions */
void do_wd(chanend c_wd, out port wd)
{
	unsigned cmd;
	unsigned shared_out = 0;

	timer t;
	unsigned ts;
	unsigned ts2;
	t :> ts;
    
    shared_out &= ~0x4;
    wd <: shared_out; // go low
    t :> ts2;
    t when timerafter(ts2+10000) :> ts2;
    shared_out |= 0x4;
    wd <: shared_out; // go high
    
    /*while(1)
    {
        t when timerafter(ts + 100000) :> ts;
        shared_out ^= 0x2;
        wd <: shared_out;
    }*/
    
    
	while (1)
	{
		select
		{
			case c_wd :> cmd:
				switch(cmd)
				{
				case WD_CMD_START: // produce a rising edge on the WD_EN
					shared_out &= ~0x4;
					wd <: shared_out; // go low
					t :> ts2;
					t when timerafter(ts2+10000) :> ts2;
					shared_out |= 0x4;
					wd <: shared_out; // go high
					break;
				}
				break;
			case t when timerafter(ts + 100000) :> ts:
				shared_out ^= 0x2;
				break;
		}
		wd <: shared_out;
	}

}
