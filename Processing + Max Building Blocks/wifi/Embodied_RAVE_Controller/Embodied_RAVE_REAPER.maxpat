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
    "rect": [
      50,
      50,
      1200,
      900
    ],
    "boxes": [
      {
        "box": {
          "id": "obj-27",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "patching_rect": [
            985.0,
            435.0,
            57.0,
            22.0
          ],
          "text": "line 0. 10"
        }
      },
      {
        "box": {
          "id": "obj-28",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            985.0,
            377.0,
            71.0,
            22.0
          ],
          "text": "pack 0. 100"
        }
      },
      {
        "box": {
          "id": "obj-30",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            985.0,
            272.0,
            97.0,
            22.0
          ],
          "text": "scale 0 127 0. 1."
        }
      },
      {
        "box": {
          "id": "obj-31",
          "maxclass": "slider",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            985.0,
            73.0,
            20.0,
            140.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-19",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            776.0,
            550.0,
            138.0,
            22.0
          ],
          "text": "udpsend 127.0.0.1 8000"
        }
      },
      {
        "box": {
          "id": "obj-20",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "patching_rect": [
            776.0,
            439.0,
            57.0,
            22.0
          ],
          "text": "line 0. 10"
        }
      },
      {
        "box": {
          "id": "obj-21",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            776.0,
            381.0,
            71.0,
            22.0
          ],
          "text": "pack 0. 100"
        }
      },
      {
        "box": {
          "id": "obj-22",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            776.0,
            490.0,
            161.0,
            22.0
          ],
          "text": "prepend /neutone/input_gain"
        }
      },
      {
        "box": {
          "id": "obj-23",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            776.0,
            276.0,
            97.0,
            22.0
          ],
          "text": "scale 0 127 0. 1."
        }
      },
      {
        "box": {
          "id": "obj-24",
          "maxclass": "slider",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            776.0,
            62.222225189208984,
            20.0,
            140.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-4",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            590.0,
            550.0,
            138.0,
            22.0
          ],
          "text": "udpsend 127.0.0.1 8000"
        }
      },
      {
        "box": {
          "id": "obj-11",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "patching_rect": [
            590.0,
            439.0,
            57.0,
            22.0
          ],
          "text": "line 0. 10"
        }
      },
      {
        "box": {
          "id": "obj-15",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            590.0,
            381.0,
            71.0,
            22.0
          ],
          "text": "pack 0. 100"
        }
      },
      {
        "box": {
          "id": "obj-16",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            590.0,
            490.0,
            119.0,
            22.0
          ],
          "text": "prepend /neutone/p1"
        }
      },
      {
        "box": {
          "id": "obj-17",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            590.0,
            276.0,
            97.0,
            22.0
          ],
          "text": "scale 0 127 0. 1."
        }
      },
      {
        "box": {
          "id": "obj-18",
          "maxclass": "slider",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            590.0,
            77.0,
            20.0,
            140.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-8",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            351.0,
            556.0,
            138.0,
            22.0
          ],
          "text": "udpsend 127.0.0.1 8000"
        }
      },
      {
        "box": {
          "id": "obj-9",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "patching_rect": [
            351.0,
            445.0,
            57.0,
            22.0
          ],
          "text": "line 0. 10"
        }
      },
      {
        "box": {
          "id": "obj-10",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            351.0,
            387.0,
            64.0,
            22.0
          ],
          "text": "pack 0. 50"
        }
      },
      {
        "box": {
          "id": "obj-12",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            351.0,
            496.0,
            157.0,
            22.0
          ],
          "text": "prepend /rave/latent_bias_1"
        }
      },
      {
        "box": {
          "id": "obj-13",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            351.0,
            282.0,
            97.0,
            22.0
          ],
          "text": "scale 0 127 0. 1."
        }
      },
      {
        "box": {
          "id": "obj-14",
          "maxclass": "slider",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            351.0,
            83.0,
            20.0,
            140.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-7",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            119.0,
            556.0,
            138.0,
            22.0
          ],
          "text": "udpsend 127.0.0.1 8000"
        }
      },
      {
        "box": {
          "id": "obj-6",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "patching_rect": [
            119.0,
            445.0,
            57.0,
            22.0
          ],
          "text": "line 0. 10"
        }
      },
      {
        "box": {
          "id": "obj-5",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            119.0,
            387.0,
            64.0,
            22.0
          ],
          "text": "pack 0. 50"
        }
      },
      {
        "box": {
          "id": "obj-3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            119.0,
            496.0,
            157.0,
            22.0
          ],
          "text": "prepend /rave/latent_bias_0"
        }
      },
      {
        "box": {
          "id": "obj-2",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            118.0,
            282.0,
            97.0,
            22.0
          ],
          "text": "scale 0 127 0. 1."
        }
      },
      {
        "box": {
          "id": "obj-1",
          "maxclass": "slider",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            118.0,
            73.0,
            20.0,
            140.0
          ]
        }
      },
      {
        "box": {
          "id": "bridge-info",
          "maxclass": "comment",
          "text": "Processing A0/A1 -> latent 0/1. Enable D in Processing. REAPER remains on port 8000.",
          "patching_rect": [
            20,
            620,
            1000,
            22
          ]
        }
      },
      {
        "box": {
          "id": "bridge-udp",
          "maxclass": "newobj",
          "text": "udpreceive 12002",
          "patching_rect": [
            20,
            660,
            260,
            22
          ]
        }
      },
      {
        "box": {
          "id": "bridge-route",
          "maxclass": "newobj",
          "text": "route /ravebridge/state",
          "patching_rect": [
            20,
            700,
            260,
            22
          ]
        }
      },
      {
        "box": {
          "id": "bridge-js",
          "maxclass": "newobj",
          "text": "js rave_sensor_bridge.js",
          "patching_rect": [
            20,
            740,
            260,
            22
          ]
        }
      },
      {
        "box": {
          "id": "bridge-reply",
          "maxclass": "newobj",
          "text": "udpsend 127.0.0.1 12003",
          "patching_rect": [
            440,
            780,
            260,
            22
          ]
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "destination": [
            "obj-2",
            0
          ],
          "source": [
            "obj-1",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-9",
            0
          ],
          "source": [
            "obj-10",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-16",
            0
          ],
          "source": [
            "obj-11",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-8",
            0
          ],
          "source": [
            "obj-12",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-10",
            0
          ],
          "source": [
            "obj-13",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-13",
            0
          ],
          "source": [
            "obj-14",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-11",
            0
          ],
          "source": [
            "obj-15",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-4",
            0
          ],
          "source": [
            "obj-16",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-15",
            0
          ],
          "source": [
            "obj-17",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-17",
            0
          ],
          "source": [
            "obj-18",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-5",
            0
          ],
          "source": [
            "obj-2",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-22",
            0
          ],
          "source": [
            "obj-20",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-20",
            0
          ],
          "source": [
            "obj-21",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-19",
            0
          ],
          "source": [
            "obj-22",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-21",
            0
          ],
          "source": [
            "obj-23",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-23",
            0
          ],
          "source": [
            "obj-24",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-27",
            0
          ],
          "source": [
            "obj-28",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-7",
            0
          ],
          "source": [
            "obj-3",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-28",
            0
          ],
          "source": [
            "obj-30",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-30",
            0
          ],
          "source": [
            "obj-31",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-6",
            0
          ],
          "source": [
            "obj-5",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-3",
            0
          ],
          "source": [
            "obj-6",
            0
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-12",
            0
          ],
          "source": [
            "obj-9",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "bridge-udp",
            0
          ],
          "destination": [
            "bridge-route",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "bridge-route",
            0
          ],
          "destination": [
            "bridge-js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "bridge-js",
            0
          ],
          "destination": [
            "obj-5",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "bridge-js",
            1
          ],
          "destination": [
            "obj-10",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "bridge-js",
            2
          ],
          "destination": [
            "bridge-reply",
            0
          ]
        }
      }
    ],
    "autosave": 0
  }
}