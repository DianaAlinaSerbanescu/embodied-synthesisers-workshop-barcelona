{
    "patcher": {
        "fileversion": 1,
        "appversion": {
            "major": 9,
            "minor": 1,
            "revision": 4,
            "architecture": "x64",
            "modernui": 1
        },
        "classnamespace": "box",
        "rect": [ -1200.0, -367.0, 1224.0, 690.0 ],
        "default_fontsize": 14.0,
        "boxes": [
            {
                "box": {
                    "id": "obj-8",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1057.0, 335.0, 176.0, 24.0 ],
                    "text": "prepend /neutone/dry_gain"
                }
            },
            {
                "box": {
                    "id": "obj-7",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 847.0, 335.0, 178.0, 24.0 ],
                    "text": "prepend /neutone/wet_gain"
                }
            },
            {
                "box": {
                    "id": "obj-6",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1057.0, 269.0, 29.5, 24.0 ],
                    "text": "0."
                }
            },
            {
                "box": {
                    "id": "obj-4",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 847.0, 269.0, 29.5, 24.0 ],
                    "text": "1."
                }
            },
            {
                "box": {
                    "id": "obj-2",
                    "maxclass": "button",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "bang" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 911.0, 150.0, 24.0, 24.0 ]
                }
            },
            {
                "box": {
                    "id": "title",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 30.0, 20.0, 700.0, 22.0 ],
                    "text": "EMBODIED NEUTONE — TWO SENSORS"
                }
            },
            {
                "box": {
                    "id": "info",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 30.0, 55.0, 740.0, 22.0 ],
                    "text": "Either stretch = play. Both relaxed = pause at current position."
                }
            },
            {
                "box": {
                    "id": "info2",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 30.0, 85.0, 750.0, 22.0 ],
                    "text": "Processing: calibrate 1/2 + R/S; D arm; L isolate selected sensor for Learn."
                }
            },
            {
                "box": {
                    "id": "udp",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 30.0, 140.0, 240.0, 24.0 ],
                    "text": "udpreceive 12000"
                }
            },
            {
                "box": {
                    "id": "route",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 2,
                    "outlettype": [ "", "" ],
                    "patching_rect": [ 30.0, 185.0, 240.0, 24.0 ],
                    "text": "route /neutone/state"
                }
            },
            {
                "box": {
                    "id": "js",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 4,
                    "outlettype": [ "", "", "", "" ],
                    "patching_rect": [ 30.0, 230.0, 240.0, 24.0 ],
                    "saved_object_attributes": {
                        "filename": "neutone_bridge.js",
                        "parameter_enable": 0
                    },
                    "text": "js neutone_bridge.js"
                }
            },
            {
                "box": {
                    "id": "float0",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "float" ],
                    "patching_rect": [ 30.0, 290.0, 100.0, 24.0 ],
                    "text": "float 0."
                }
            },
            {
                "box": {
                    "id": "p0",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 30.0, 335.0, 230.0, 24.0 ],
                    "text": "prepend /neutone/p1"
                }
            },
            {
                "box": {
                    "id": "float1",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "float" ],
                    "patching_rect": [ 290.0, 290.0, 100.0, 24.0 ],
                    "text": "float 0."
                }
            },
            {
                "box": {
                    "id": "p1",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 290.0, 335.0, 230.0, 24.0 ],
                    "text": "prepend /neutone/p2"
                }
            },
            {
                "box": {
                    "id": "action",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 550.0, 335.0, 190.0, 24.0 ],
                    "text": "prepend /action"
                }
            },
            {
                "box": {
                    "id": "send",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 290.0, 395.0, 250.0, 24.0 ],
                    "text": "udpsend 127.0.0.1 8000"
                }
            },
            {
                "box": {
                    "id": "feed",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 30.0, 460.0, 260.0, 24.0 ],
                    "text": "prepend /neutone/feedback"
                }
            },
            {
                "box": {
                    "id": "back",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 30.0, 505.0, 250.0, 24.0 ],
                    "text": "udpsend 127.0.0.1 12001"
                }
            },
            {
                "box": {
                    "id": "close",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "bang" ],
                    "patching_rect": [ 550.0, 460.0, 130.0, 24.0 ],
                    "text": "closebang"
                }
            },
            {
                "box": {
                    "id": "closemsg",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 550.0, 505.0, 130.0, 24.0 ],
                    "text": "closebang"
                }
            },
            {
                "box": {
                    "id": "help",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 30.0, 560.0, 750.0, 22.0 ],
                    "text": "REAPER produces the audio. Max DSP does not need to be enabled."
                }
            },
            {
                "box": {
                    "id": "help2",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 30.0, 590.0, 800.0, 22.0 ],
                    "text": "Keep neutone_bridge.js beside this patch. Missing Processing data pauses after 500 ms."
                }
            },
            {
                "box": {
                    "id": "help3",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 30.0, 620.0, 800.0, 22.0 ],
                    "text": "Feedback confirms Max received controls; it does not confirm REAPER received them."
                }
            }
        ],
        "lines": [
            {
                "patchline": {
                    "destination": [ "send", 0 ],
                    "source": [ "action", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "closemsg", 0 ],
                    "source": [ "close", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "js", 0 ],
                    "source": [ "closemsg", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "back", 0 ],
                    "source": [ "feed", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "p0", 0 ],
                    "source": [ "float0", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "p1", 0 ],
                    "source": [ "float1", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "action", 0 ],
                    "source": [ "js", 2 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "feed", 0 ],
                    "source": [ "js", 3 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "float0", 0 ],
                    "source": [ "js", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "float1", 0 ],
                    "source": [ "js", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-4", 0 ],
                    "order": 1,
                    "source": [ "obj-2", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-6", 0 ],
                    "order": 0,
                    "source": [ "obj-2", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-7", 0 ],
                    "source": [ "obj-4", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-8", 0 ],
                    "source": [ "obj-6", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "send", 0 ],
                    "source": [ "obj-7", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "send", 0 ],
                    "source": [ "obj-8", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "send", 0 ],
                    "source": [ "p0", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "send", 0 ],
                    "source": [ "p1", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "js", 0 ],
                    "source": [ "route", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "route", 0 ],
                    "source": [ "udp", 0 ]
                }
            }
        ],
        "autosave": 0
    }
}