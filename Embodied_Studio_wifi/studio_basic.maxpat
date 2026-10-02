{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 9,
      "minor": 0,
      "revision": 0,
      "architecture": "x64",
      "modernui": 1
    },
    "rect": [
      40,
      40,
      1200,
      850
    ],
    "boxes": [
      {
        "box": {
          "id": "in",
          "maxclass": "inlet",
          "patching_rect": [
            20,
            20,
            30,
            22
          ]
        }
      },
      {
        "box": {
          "id": "js",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            60,
            180,
            22
          ],
          "text": "js studio_basic.js"
        }
      },
      {
        "box": {
          "id": "u0",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            110,
            180,
            22
          ],
          "text": "unpack i f f"
        }
      },
      {
        "box": {
          "id": "fp0",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            150,
            180,
            22
          ],
          "text": "pack 0. 30"
        }
      },
      {
        "box": {
          "id": "fl0",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            190,
            180,
            22
          ],
          "text": "line~ 100."
        }
      },
      {
        "box": {
          "id": "sine0",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            235,
            180,
            22
          ],
          "text": "cycle~"
        }
      },
      {
        "box": {
          "id": "mul02",
          "maxclass": "newobj",
          "patching_rect": [
            150,
            190,
            90,
            22
          ],
          "text": "*~ 2"
        }
      },
      {
        "box": {
          "id": "h02",
          "maxclass": "newobj",
          "patching_rect": [
            150,
            235,
            90,
            22
          ],
          "text": "cycle~"
        }
      },
      {
        "box": {
          "id": "w02",
          "maxclass": "newobj",
          "patching_rect": [
            150,
            270,
            90,
            22
          ],
          "text": "*~ 0.5"
        }
      },
      {
        "box": {
          "id": "mul03",
          "maxclass": "newobj",
          "patching_rect": [
            280,
            190,
            90,
            22
          ],
          "text": "*~ 3"
        }
      },
      {
        "box": {
          "id": "h03",
          "maxclass": "newobj",
          "patching_rect": [
            280,
            235,
            90,
            22
          ],
          "text": "cycle~"
        }
      },
      {
        "box": {
          "id": "w03",
          "maxclass": "newobj",
          "patching_rect": [
            280,
            270,
            90,
            22
          ],
          "text": "*~ 0.3"
        }
      },
      {
        "box": {
          "id": "sum0",
          "maxclass": "newobj",
          "patching_rect": [
            170,
            310,
            180,
            22
          ],
          "text": "*~ 0.555555556"
        }
      },
      {
        "box": {
          "id": "noise0",
          "maxclass": "newobj",
          "patching_rect": [
            400,
            190,
            90,
            22
          ],
          "text": "noise~"
        }
      },
      {
        "box": {
          "id": "filter0",
          "maxclass": "newobj",
          "patching_rect": [
            360,
            235,
            150,
            22
          ],
          "text": "lores~ 40 0."
        }
      },
      {
        "box": {
          "id": "select0",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            350,
            180,
            22
          ],
          "text": "selector~ 3"
        }
      },
      {
        "box": {
          "id": "gp0",
          "maxclass": "newobj",
          "patching_rect": [
            280,
            350,
            180,
            22
          ],
          "text": "pack 0. 30"
        }
      },
      {
        "box": {
          "id": "gl0",
          "maxclass": "newobj",
          "patching_rect": [
            280,
            390,
            180,
            22
          ],
          "text": "line~ 0."
        }
      },
      {
        "box": {
          "id": "amp0",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            430,
            180,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "pan00",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            470,
            140,
            22
          ],
          "text": "*~ 0.951057"
        }
      },
      {
        "box": {
          "id": "pan01",
          "maxclass": "newobj",
          "patching_rect": [
            170,
            470,
            140,
            22
          ],
          "text": "*~ 0.309017"
        }
      },
      {
        "box": {
          "id": "u1",
          "maxclass": "newobj",
          "patching_rect": [
            540,
            110,
            180,
            22
          ],
          "text": "unpack i f f"
        }
      },
      {
        "box": {
          "id": "fp1",
          "maxclass": "newobj",
          "patching_rect": [
            540,
            150,
            180,
            22
          ],
          "text": "pack 0. 30"
        }
      },
      {
        "box": {
          "id": "fl1",
          "maxclass": "newobj",
          "patching_rect": [
            540,
            190,
            180,
            22
          ],
          "text": "line~ 100."
        }
      },
      {
        "box": {
          "id": "sine1",
          "maxclass": "newobj",
          "patching_rect": [
            540,
            235,
            180,
            22
          ],
          "text": "cycle~"
        }
      },
      {
        "box": {
          "id": "mul12",
          "maxclass": "newobj",
          "patching_rect": [
            670,
            190,
            90,
            22
          ],
          "text": "*~ 2"
        }
      },
      {
        "box": {
          "id": "h12",
          "maxclass": "newobj",
          "patching_rect": [
            670,
            235,
            90,
            22
          ],
          "text": "cycle~"
        }
      },
      {
        "box": {
          "id": "w12",
          "maxclass": "newobj",
          "patching_rect": [
            670,
            270,
            90,
            22
          ],
          "text": "*~ 0.5"
        }
      },
      {
        "box": {
          "id": "mul13",
          "maxclass": "newobj",
          "patching_rect": [
            800,
            190,
            90,
            22
          ],
          "text": "*~ 3"
        }
      },
      {
        "box": {
          "id": "h13",
          "maxclass": "newobj",
          "patching_rect": [
            800,
            235,
            90,
            22
          ],
          "text": "cycle~"
        }
      },
      {
        "box": {
          "id": "w13",
          "maxclass": "newobj",
          "patching_rect": [
            800,
            270,
            90,
            22
          ],
          "text": "*~ 0.3"
        }
      },
      {
        "box": {
          "id": "sum1",
          "maxclass": "newobj",
          "patching_rect": [
            690,
            310,
            180,
            22
          ],
          "text": "*~ 0.555555556"
        }
      },
      {
        "box": {
          "id": "noise1",
          "maxclass": "newobj",
          "patching_rect": [
            920,
            190,
            90,
            22
          ],
          "text": "noise~"
        }
      },
      {
        "box": {
          "id": "filter1",
          "maxclass": "newobj",
          "patching_rect": [
            880,
            235,
            150,
            22
          ],
          "text": "lores~ 40 0."
        }
      },
      {
        "box": {
          "id": "select1",
          "maxclass": "newobj",
          "patching_rect": [
            540,
            350,
            180,
            22
          ],
          "text": "selector~ 3"
        }
      },
      {
        "box": {
          "id": "gp1",
          "maxclass": "newobj",
          "patching_rect": [
            800,
            350,
            180,
            22
          ],
          "text": "pack 0. 30"
        }
      },
      {
        "box": {
          "id": "gl1",
          "maxclass": "newobj",
          "patching_rect": [
            800,
            390,
            180,
            22
          ],
          "text": "line~ 0."
        }
      },
      {
        "box": {
          "id": "amp1",
          "maxclass": "newobj",
          "patching_rect": [
            540,
            430,
            180,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "pan10",
          "maxclass": "newobj",
          "patching_rect": [
            540,
            470,
            140,
            22
          ],
          "text": "*~ 0.309017"
        }
      },
      {
        "box": {
          "id": "pan11",
          "maxclass": "newobj",
          "patching_rect": [
            690,
            470,
            140,
            22
          ],
          "text": "*~ 0.951057"
        }
      },
      {
        "box": {
          "id": "out0",
          "maxclass": "outlet",
          "patching_rect": [
            20,
            600,
            30,
            22
          ]
        }
      },
      {
        "box": {
          "id": "out1",
          "maxclass": "outlet",
          "patching_rect": [
            260,
            600,
            30,
            22
          ]
        }
      },
      {
        "box": {
          "id": "feedback",
          "maxclass": "outlet",
          "patching_rect": [
            800,
            600,
            30,
            22
          ]
        }
      },
      {
        "box": {
          "id": "change0gain",
          "maxclass": "newobj",
          "text": "change 0.",
          "patching_rect": [
            20,
            720,
            100,
            22
          ]
        }
      },
      {
        "box": {
          "id": "change0freq",
          "maxclass": "newobj",
          "text": "change 0.",
          "patching_rect": [
            20,
            680,
            100,
            22
          ]
        }
      },
      {
        "box": {
          "id": "change1gain",
          "maxclass": "newobj",
          "text": "change 0.",
          "patching_rect": [
            540,
            720,
            100,
            22
          ]
        }
      },
      {
        "box": {
          "id": "change1freq",
          "maxclass": "newobj",
          "text": "change 0.",
          "patching_rect": [
            540,
            680,
            100,
            22
          ]
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "source": [
            "in",
            0
          ],
          "destination": [
            "js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "js",
            0
          ],
          "destination": [
            "u0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "u0",
            1
          ],
          "destination": [
            "change0freq",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fp0",
            0
          ],
          "destination": [
            "fl0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fl0",
            0
          ],
          "destination": [
            "sine0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fl0",
            0
          ],
          "destination": [
            "mul02",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mul02",
            0
          ],
          "destination": [
            "h02",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "h02",
            0
          ],
          "destination": [
            "w02",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fl0",
            0
          ],
          "destination": [
            "mul03",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mul03",
            0
          ],
          "destination": [
            "h03",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "h03",
            0
          ],
          "destination": [
            "w03",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sine0",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "w02",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "w03",
            0
          ],
          "destination": [
            "sum0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "noise0",
            0
          ],
          "destination": [
            "filter0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fl0",
            0
          ],
          "destination": [
            "filter0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "u0",
            0
          ],
          "destination": [
            "select0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sine0",
            0
          ],
          "destination": [
            "select0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sum0",
            0
          ],
          "destination": [
            "select0",
            2
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "filter0",
            0
          ],
          "destination": [
            "select0",
            3
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "u0",
            2
          ],
          "destination": [
            "change0gain",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gp0",
            0
          ],
          "destination": [
            "gl0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "select0",
            0
          ],
          "destination": [
            "amp0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gl0",
            0
          ],
          "destination": [
            "amp0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "amp0",
            0
          ],
          "destination": [
            "pan00",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "amp0",
            0
          ],
          "destination": [
            "pan01",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "js",
            1
          ],
          "destination": [
            "u1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "u1",
            1
          ],
          "destination": [
            "change1freq",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fp1",
            0
          ],
          "destination": [
            "fl1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fl1",
            0
          ],
          "destination": [
            "sine1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fl1",
            0
          ],
          "destination": [
            "mul12",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mul12",
            0
          ],
          "destination": [
            "h12",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "h12",
            0
          ],
          "destination": [
            "w12",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fl1",
            0
          ],
          "destination": [
            "mul13",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mul13",
            0
          ],
          "destination": [
            "h13",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "h13",
            0
          ],
          "destination": [
            "w13",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sine1",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "w12",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "w13",
            0
          ],
          "destination": [
            "sum1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "noise1",
            0
          ],
          "destination": [
            "filter1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "fl1",
            0
          ],
          "destination": [
            "filter1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "u1",
            0
          ],
          "destination": [
            "select1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sine1",
            0
          ],
          "destination": [
            "select1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sum1",
            0
          ],
          "destination": [
            "select1",
            2
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "filter1",
            0
          ],
          "destination": [
            "select1",
            3
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "u1",
            2
          ],
          "destination": [
            "change1gain",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gp1",
            0
          ],
          "destination": [
            "gl1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "select1",
            0
          ],
          "destination": [
            "amp1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gl1",
            0
          ],
          "destination": [
            "amp1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "amp1",
            0
          ],
          "destination": [
            "pan10",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "amp1",
            0
          ],
          "destination": [
            "pan11",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "pan00",
            0
          ],
          "destination": [
            "out0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "pan10",
            0
          ],
          "destination": [
            "out0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "pan01",
            0
          ],
          "destination": [
            "out1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "pan11",
            0
          ],
          "destination": [
            "out1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "js",
            2
          ],
          "destination": [
            "feedback",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "change0gain",
            0
          ],
          "destination": [
            "gp0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "change0freq",
            0
          ],
          "destination": [
            "fp0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "change1gain",
            0
          ],
          "destination": [
            "gp1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "change1freq",
            0
          ],
          "destination": [
            "fp1",
            0
          ]
        }
      }
    ]
  }
}