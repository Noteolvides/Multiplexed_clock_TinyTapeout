
>This is my first proyect in verilog so i have decided to do something simple and in future maybe i will try something harder! Half of the code if copied form Matt [code](https://github.com/mattvenn/tt04-vga-clock/blob/main/src/vga_clock.v).

>The code is ready to test in the Tang Nano, you have a branch already created for that called [tang_nano_development](https://github.com/Noteolvides/Noteolvides_clock_TinyTapeout/tree/tang_nano_development)

![Tang Nano Clock](https://github.com/Noteolvides/Noteolvides_clock_TinyTapeout/assets/28985425/04811332-4ded-41cd-818d-212c6237f6e6)


>Here in the video the clock was speeded 10%

https://github.com/Noteolvides/Noteolvides_clock_TinyTapeout/assets/28985425/c1f09e6a-ff84-4910-b4ba-b7dd94319d81


# How it works
Basically this is a clock that counts minutes shows the hours in the 24-hour format, it uses the dot in the 7 segments to indicate 15s 30s 45s and 60s respectibly.

```
      -- 0 --         -- 0 --         -- 0 --         -- 0 --   
     |       |       |       |       |       |       |       |  
     5       1       5       1       5       1       5       1  
     |       |       |       |       |       |       |       |  
      -- 6 --         -- 6 --         -- 6 --         -- 6 --   
     |       |       |       |       |       |       |       |  
     4       2       4       2       4       2       4       2  
     |       |       |       |       |       |       |       |  
      -- 3 --  :60s   -- 3 --  :45s   -- 3 --  :30s   -- 3 --  :15s
         ↑               ↑               ↑               ↑    
      Hours H         Hours L         Minutes H       Minutes L
     uio_out[3]      uio_out[2]       uio_out[1]      uio_out[0]     
```

[6:0] of the seven segments are connected to the **uo_out** output and the 7 bit is for the dot of the seven sevements.
The digist are multiplexed, each digit is shown 1ms, those pins are **uio_out[3:0]** and **uio_out[5:4]** are used for debuging showing the clock of the seconds and minutes.

For the test i have used [this 7 segment](https://www.tme.eu/es/details/kw4-804cgb/7-segment-led-displays/luckylight/?utm_campaign=compare-2019-08&utm_medium=cpc&utm_source=findchips.com) with common Cathode. But you can use which ever 7 segmnet display of 4 digits common or anode thats to the pins **ui_in[3:2]** with are use to negate the 7 segmetents or the multixplexing. 

Finally, **ui_in[1:0]** are used with a button to increase the hours or minutes.


# How to test 
I have selected a clock 32,768khz because i thought it will be easy to buy a ready commponent that generates a squera wave with that frecuency, we will see about that :stuck_out_tongue_closed_eyes:.
Just connect the 7 segments to the **uo_out** pins and select your configuration anode or catothe with the **ui_in[3]** pin.
For the multiplexing connected uio_out[3:0] to the digits as show in how to use drawing.

And finally if you want to increase the numbers connect a button pull up to the pins **ui_in[1:0]** to increase hours or minutes.

Generate a reset to start to init all the registers.
