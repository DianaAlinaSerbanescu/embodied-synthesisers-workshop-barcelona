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
      701.0,
      -814.0,
      1000.0,
      780.0
    ],
    "boxes": [
      {
        "box": {
          "id": "obj-15",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "patching_rect": [
            600.0,
            403.0,
            57.0,
            22.0
          ],
          "text": "line 0. 10"
        }
      },
      {
        "box": {
          "id": "obj-14",
          "maxclass": "newobj",
          "numinlets": 3,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "patching_rect": [
            361.0,
            398.0,
            57.0,
            22.0
          ],
          "text": "line 0. 10"
        }
      },
      {
        "box": {
          "id": "obj-13",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            599.0,
            355.0,
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
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            361.0,
            355.0,
            64.0,
            22.0
          ],
          "text": "pack 0. 50"
        }
      },
      {
        "box": {
          "id": "obj-7",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            599.0,
            502.0,
            138.0,
            22.0
          ],
          "text": "udpsend 127.0.0.1 8000"
        }
      },
      {
        "box": {
          "id": "obj-8",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            600.0,
            449.0,
            154.0,
            22.0
          ],
          "text": "prepend /track/2/volume/db"
        }
      },
      {
        "box": {
          "format": 6,
          "id": "obj-9",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0,
          "patching_rect": [
            599.0,
            309.0,
            50.0,
            22.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-10",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            599.0,
            262.0,
            107.0,
            22.0
          ],
          "text": "scale 0 127 -60. 0."
        }
      },
      {
        "box": {
          "id": "obj-11",
          "maxclass": "slider",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            599.0,
            95.0,
            20.0,
            140.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-6",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            361.0,
            502.0,
            138.0,
            22.0
          ],
          "text": "udpsend 127.0.0.1 8000"
        }
      },
      {
        "box": {
          "id": "obj-5",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            362.0,
            442.0,
            154.0,
            22.0
          ],
          "text": "prepend /track/1/volume/db"
        }
      },
      {
        "box": {
          "format": 6,
          "id": "obj-4",
          "maxclass": "flonum",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "",
            "bang"
          ],
          "parameter_enable": 0,
          "patching_rect": [
            361.0,
            305.0,
            50.0,
            22.0
          ]
        }
      },
      {
        "box": {
          "id": "obj-3",
          "maxclass": "newobj",
          "numinlets": 6,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            361.0,
            258.0,
            107.0,
            22.0
          ],
          "text": "scale 0 127 -60. 0."
        }
      },
      {
        "box": {
          "id": "obj-2",
          "maxclass": "slider",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "parameter_enable": 0,
          "patching_rect": [
            361.0,
            91.0,
            20.0,
            140.0
          ]
        }
      },
      {
        "box": {
          "id": "input",
          "maxclass": "inlet",
          "patching_rect": [
            20,
            30,
            30,
            22
          ]
        }
      },
      {
        "box": {
          "id": "bridge",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            80,
            260,
            22
          ],
          "text": "js studio_volume.js"
        }
      },
      {
        "box": {
          "id": "feedback",
          "maxclass": "outlet",
          "patching_rect": [
            20,
            570,
            30,
            22
          ]
        }
      },
      {
        "box": {
          "id": "label",
          "maxclass": "comment",
          "patching_rect": [
            20,
            620,
            260,
            22
          ],
          "text": "Sensor A0: track 1 / A1: track 2. -60 to 0 dB. Hold is not mute."
        }
      }
    ],
    "lines": [
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
            "obj-10",
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
            "obj-14",
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
            "obj-15",
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
            "obj-5",
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
            "obj-8",
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
            "obj-3",
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
            "obj-4",
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
            "obj-12",
            0
          ],
          "source": [
            "obj-4",
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
            "obj-7",
            0
          ],
          "source": [
            "obj-8",
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
            "obj-9",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "input",
            0
          ],
          "destination": [
            "bridge",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "bridge",
            0
          ],
          "destination": [
            "obj-4",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "bridge",
            1
          ],
          "destination": [
            "obj-9",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "bridge",
            2
          ],
          "destination": [
            "feedback",
            0
          ]
        }
      }
    ],
    "autosave": 0,
    "oscreceiveudpport": 0
  }
}