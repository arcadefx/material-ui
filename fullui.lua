    mui.newIconButton({
            parent = mui.getParent(),
            name = "plus",
            text = "help",
            width = 30,
            height = 30,
            x = 260,
            y = 140,
            isFontIcon = false,
            font = mui.materialFont,
            state = {
                value = "disabled", -- specify the state to be in when button is created
                off = {
                    textColor = {0.25, 0.75, 1, 1},
                    callBack = buttonMessage,
                    callBackData = {message = "button is turned off"},
                    ---[[--
                    svg = {
                        path = "ic_help_48px.svg",
                        fillColor = {0.25, 0.75, 1, 1},
                    }
                    ---]]--
                },
                on = {
                    textColor = {1, 0, 0, 1},
                    callBack = buttonMessage,
                    callBackData = {message = "button is turned on"},
                    ---[[--
                    svg = {
                        path = "ic_school_48px.svg",
                        fillColor = {0, 1, 0, 1},
                    }
                    ---]]--
                },
                disabled = {
                    textColor = {0.7, 0.7, 0.7, 1},
                    callBack = buttonMessage,
                    callBackData = {message = "button is disabled"},
                    ---[[--
                    svg = {
                        path = "ic_help_48px.svg",
                        fillColor = {0.7, 0.7, 0.7, 1}
                    }
                    --]]--
                }
            },
            callBack = nil, -- mui.actionSwitchScene,
            callBackData = {
                sceneDestination = "onboard",
                sceneTransitionColor = {0.08, 0.9, 0.31}}})


    -- dialog box example
    -- use mui.getWidgetBaseObject("dialog_demo") to get surface to add more content
    local showDialog = function(e)
        local muiTargetValue = mui.getEventParameter(e, "muiTargetValue")
        local muiTargetCallBackData = mui.getEventParameter(e, "muiTargetCallBackData")
        -- mui.debug("data passed: "..muiTargetCallBackData.food)
            mui.newDialog({
            name = "dialog_demo",
            width = 350,
            height = 200,
            text = "Do you want to continue?",
            textX = 0,
            textY = 0,
            textColor = { 0, 0, 0, 1 },
            font = native.systemFont,
            fontSize = 18,
            fillColor = { 1, 1, 1, 1 },
            background = "TextBackground.jpg",
            gradientBorderShadowColor1 = { 1, 1, 1, 0.4 },
            gradientBorderShadowColor2 = { 0, 0, 0, 0.4 },
            easing = easing.inOutCubic, -- this is default if omitted
            buttons = {
                font = native.systemFont,
                okayButton = {
                    text = "Okay",
                    textColor = { 0, 0, 0 },
                    fillColor = { 1, 1, 1 },
                    width = 100,
                    height = 35,
                    callBackOkay = mui.actionForOkayDialog,
                    clickAnimation = {
                        fillColor = { 0.4, 0.4, 0.4, 0.4 },
                        time = 400
                    }
                },
                cancelButton = {
                    text = "Cancel",
                    textColor = { 0, 0, 0 },
                    fillColor = { 1, 1, 1 },
                    width = 100,
                    height = 35,
                    clickAnimation = {
                        fillColor = { 0.4, 0.4, 0.4, 0.4 },
                        time = 400
                    }
                }
            }
        })
    end

    mui.newRoundedRectButton({
            parent = mui.getParent(),
            name = "newDialog",
            text = "Open Dialog",
            width = 150,
            height = 40,
            x = 90,
            y = 150,
            radius = 10,
            font = native.systemFont,
            iconAlign = "left",
            state = {
                value = "off",
                off = {
                    textColor = {1, 1, 1},
                    fillColor = {0, 0.81, 1}
                    --svg = {path = "ic_view_list_48px.svg"}
                },
                on = {
                    textColor = {1, 1, 1},
                    fillColor = {0, 0.61, 1}
                    --svg = {path = "ic_help_48px.svg"}
                },
                disabled = {
                    textColor = {1, 1, 1},
                    fillColor = {.3, .3, .3}
                    --svg = {path = "ic_help_48px.svg"}
                }
            },
            gradientShadowColor1 = {0.9, 0.9, 0.9, 255},
            gradientShadowColor2 = {0.9, 0.9, 0.9, 0},
            gradientDirection = "up",
            callBack = showDialog,
            callBackData = {message = "newDialog callBack called"}, -- demo passing data to an event
        })

    local resizeTest = function(e)
        -- body
        local testSvg = mui.getImageSvgProperty("plus", "object")
        if testSvg ~= nil then
            testSvg.xScale = testSvg.xScale + 0.1
            testSvg.yScale = testSvg.yScale + 0.1
        end
    end

    mui.newRectButton({
            parent = mui.getParent(),
            name = "switchSceneButton",
            text = "Go Bigger",
            width = 100,
            height = 30,
            x = 70,
            y = 80,
            iconAlign = "left", -- left, right supported
            font = native.systemFont,
            fontSize = 16,
            iconFont = mui.materialFont,
            state = {
                value = "disabled",
                off = {
                    textColor = {1, 1, 1},
                    fillColor = {0.25, 0.75, 1, 1},
                    iconFontColor = {1, 1, 1, 1},
                    iconText = "picture_in_picture",
                    -- iconImage = "1484026171_02.png",
                },
                on = {
                    textColor = {1, 1, 1},
                    fillColor = {1, 0, 0, 1},
                    iconFontColor = {1, 1, 1, 1},
                    iconText = "picture_in_picture",
                    -- iconImage = "1484022678_go-home.png",
                },
                disabled = {
                    textColor = {1,1,1,1},
                    fillColor = {0.7, 0.7, 0.7, 1},
                    iconFontColor = {1, 1, 1, 1},
                    iconText = "picture_in_picture",
                    -- iconImage = "1484022678_go-home.png",
                },
            },
            touchpoint = true,
            callBack = resizeTest,
            callBackData = {
                sceneDestination = "fun",
                sceneTransitionColor = {0, 0.73, 1},
                sceneTransitionAnimation = true
            } -- scene fun.lua
        })

    -- date picker example
    local showDatePicker = function(event)
        mui.newDatePicker({
            parent = mui.getParent(),
            name = "datepicker-demo",
            font = native.systemFont,
            fontSize = 18,
            width = 300,
            height = 200,
            fontColor = { 0.7, 0.7, 0.7, 1 }, -- non-select items
            fontColorSelected = { 0, 0, 0, 1 }, -- selected items
            columnColor = { 1, 1, 1, 1 }, -- background color for columns
            strokeColor = { 0.25, 0.75, 1, 1 }, -- the border color around widget
            gradientBorderShadowColor1 = { 1, 1, 1, 0.2 },
            gradientBorderShadowColor2 = { 1, 1, 1, 1 },
            background = "TextBackground.jpg",
            fromYear = 1969,
            toYear = 2020,
            startMonth = 11,
            startDay = 15,
            startYear = 2015,
            cancelButtonText = "Cancel",
            cancelButtonTextColor = { 1, 1, 1, 1 },
            cancelButtonFillColor = { 0.25, 0.75, 1, 1 },
            submitButtonText = "Set",
            submitButtonFillColor = { 0.25, 0.75, 1, 1 },
            submitButtonTextColor = { 1, 1, 1, 1 },
            callBack = mui.datePickerCallBack,
        })
    end

    mui.newCircleButton({
            parent = mui.getParent(),
            name = "alice-button",
            text = "date_range",
            radius = 30,
            x = 260,
            y = 80,
            isFontIcon = true,
            font = mui.materialFont,
            state = {
                off = {
                    textColor = {1, 1, 1, 1},
                    fillColor = {0.25, 0.75, 1, 1},
                    svg = {
                        path = "ic_school_48px.svg",
                        fillColor = {0, 0.81, 1},
                }},
                on = {
                    textColor = {1, 1, 1, 1},
                    fillColor = {1, 0, 0, 1},
                    svg = {
                        path = "ic_help_48px.svg",
                        fillColor = {0, 0.81, 1},
                }},
                disabled = {
                    textColor = {.3, .3, .3, 1},
                    fillColor = {0.3, 0.3, 0.3, 1}
                }
            },
            callBack = showDatePicker,
        })
    -- mui.turnOnButtonByName("alice-button")

    mui.newRadioGroup({
            parent = mui.getParent(),
            name = "radio_demo",
            width = 18,
            height = 18,
            x = 60,
            y = 30,
            layout = "horizontal",
            labelFont = native.systemFont,
            state = {
                value = "off",
                off = {
                    textColor = {0, 0, 0},
                    labelColor = {0, 0, 0},
                },
                on = {
                    textColor = {1, 0, 0},
                    labelColor = {1, 0, 0},
                },
                disabled = {
                    textColor = {.3, .3, .3},
                    labelColor = {.3, .3, .3},
            }},
            callBack = mui.actionForRadioButton,
            list = {
                {key = "Cookie", value = "1", isChecked = false},
                {key = "Fruit Snack", value = "2", isChecked = false},
                {key = "Grape", value = "3", isChecked = true}}})

    mui.newCheckBox({
            parent = mui.getParent(),
            name = "check",
            text = "check_box_outline_blank",
            width = 25,
            height = 25,
            x = 180,
            y = 80,
            isFontIcon = true,
            font = mui.materialFont,
            state = {
                value = "off",
                off = {
                    textColor = {0.3, 0.3, 0.3},
                    svg = {
                        path = "ic_check_box_outline_blank_48px.svg",
                        fillColor = {0.3, 0.3, 0.3},
                }},
                on = {
                    textColor = {.3, .3, .3},
                    svg = {
                        path = "ic_check_box_48px.svg",
                        fillColor = {0.3, 0.3, 0.3},
                }},
                disabled = {
                    textColor = {1, 0, 0},
                    svg = {
                        path = "ic_check_box_48px.svg",
                        fillColor = {1, 0, 0},
                    }
                }
            },
            textAlign = "center",
            value = 900,
            callBack = mui.actionForCheckbox
        })

    local o = mui.getWidgetBaseObject("newDialog")
    --[[--
    transition.bounce(o, {
            height = -20, -- Set to negative value to bounce downwards
            time = 4000,
            iterations = 0,
            y = o.y + 300
        })
    --]]--

    mui.newNavbar({
        name = "navbar_demo",
        --width = display.contentWidth,
        background = "Vqjr2iR.jpg",
        height = 40,
        left = 0,
        top = 0,
        fillColor = { 0.63, 0.81, 0.181 },
        activeTextColor = { 1, 1, 1, 1 },
        padding = 5,
    })

    mui.newIconButton({
        name = "menu",
        text = "menu",
        width = 25,
        height = 25,
        x = 0,
        y = 0,
        font = mui.materialFont,
        state = {
            off = {
                textColor = { 1, 1, 1 }
            },
            on = {
                textColor = { 1, 1, 1 }
            }
        },
        textAlign = "center",
        callBack = showSlidePanel2
    })
    mui.attachToNavBar( "navbar_demo", {
        widgetName = "menu",
        widgetType = "IconButton",
        align = "left",  -- left | right supported
    })


    local buttonHeight = 40
    mui.newToolbar({
        parent = mui.getParent(),
        name = "toolbar_demo",
        height = buttonHeight,
        buttonHeight = buttonHeight,
        x = 0,
        y = (muiData.safeAreaHeight - (buttonHeight * 0.5)),
        layout = "horizontal",
        labelFont = native.systemFont,
        fillColor = { 0, 0.46, 1, 1 },
        background = "light-blue-canvas-fabric-texture.jpg",
        sliderColor = { 1, 1, 1 },
        callBack = mui.actionForToolbarDemo,
        list = {
            -- note use iconImage="<filename of jpg/png>" for custom graphic icons
            { 
                key = "Home", 
                value = "1", 
                icon="home", 
                --labelText="Home", 
                isActive = true, 
                iconImageOn = nil,
                state = {
                    value = "on",
                    off = {
                        textColor = { 1,1,1,1 },
                        strokeColor = { .3,.3,.3,1 },
                        labelColor = { 1,1,1,1 },
                        xsvg = {
                            path = "ic_home_48px.svg",
                        }
                    },
                    on = {
                        textColor = { 1,0,0,1 },
                        strokeColor = { .3,.3,.3,1 },
                        labelColor = { 1,0,0,1 },
                        xsvg = {
                            path = "ic_home_48px.svg",
                        }
                    },
                    disabled = {
                        textColor = { .7,.7,.7,1 },
                        strokeColor = { .7,.7,.7,1 },
                        labelColor = { .7,.7,.7,1 },
                        xsvg = {
                            path = "ic_home_48px.svg",
                        }
                    },
                    image = {
                        src = "if-hi-1024.png", -- source image file
                        -- Below is optional if you have buttons on a sheet
                        -- The 'sheetOptions' is directly from Corona sheets
                        sheetIndex = 1, -- which frame to show for image from sheet
                        touchIndex = 2, -- which frame to show for touch event
                        disabledIndex = -1, -- which frame to show when disabled
                        touchFadeAnimation = true, -- helpful with shadows
                        touchFadeAnimationSpeedOut = 500,
                        sheetOptions = {
                            -- The params below are required by Corona

                            width = 512,
                            height = 512,
                            numFrames = 2,

                            -- The params below are optional (used for dynamic image sheet selection)

                            sheetContentWidth = 1024,  -- width of original 1x size of entire sheet
                            sheetContentHeight = 512  -- height of original 1x size of entire sheet

                        }
                    }
                }
            },
            { 
                key = "Newsroom",
                value = "2",
                icon="new_releases",
                --labelText="News",
                isActive = false,
                state = {
                    off = {
                        textColor = { 1,1,1,1 },
                        strokeColor = { .3,.3,.3,1 },
                        labelColor = { 1,1,1,1 },
                        xsvg = {
                            path = "ic_new_releases_48px.svg",
                        }
                    },
                    on = {
                        textColor = { 1,0,0,1 },
                        strokeColor = { .3,.3,.3,1 },
                        labelColor = { 1,0,0,1 },
                        xsvg = {
                            path = "ic_new_releases_48px.svg",
                        }
                    },
                    disabled = {
                        textColor = { .7,.7,.7,1 },
                        strokeColor = { .7,.7,.7,1 },
                        labelColor = { .7,.7,.7,1 },
                        xsvg = {
                            path = "ic_new_releases_48px.svg",
                        }
                    },
                    image = {
                        src = "if-vimeo-1024.png", -- source image file
                        -- Below is optional if you have buttons on a sheet
                        -- The 'sheetOptions' is directly from Corona sheets
                        sheetIndex = 1, -- which frame to show for image from sheet
                        touchIndex = 2, -- which frame to show for touch event
                        disabledIndex = -1, -- which frame to show when disabled
                        touchFadeAnimation = true, -- helpful with shadows
                        touchFadeAnimationSpeedOut = 500,
                        sheetOptions = {
                            -- The params below are required by Corona

                            width = 512,
                            height = 512,
                            numFrames = 2,

                            -- The params below are optional (used for dynamic image sheet selection)

                            sheetContentWidth = 1024,  -- width of original 1x size of entire sheet
                            sheetContentHeight = 512  -- height of original 1x size of entire sheet

                        }
                    }
                }
            },
            { 
                key = "Location",
                value = "3",
                icon="location_searching",
                --labelText="Location",
                isActive = false,
                state = {
                    off = {
                        textColor = { 1,1,1,1 },
                        strokeColor = { .3,.3,.3,1 },
                        labelColor = { 1,1,1,1 },
                        xsvg = {
                            path = "ic_location_searching_48px.svg",
                        }
                    },
                    on = {
                        textColor = { 1,0,0,1 },
                        strokeColor = { .3,.3,.3,1 },
                        labelColor = { 1,0,0,1 },
                        xsvg = {
                            path = "ic_location_searching_48px.svg",
                        }
                    },
                    disabled = {
                        textColor = { .7,.7,.7,1 },
                        strokeColor = { .7,.7,.7,1 },
                        labelColor = { .7,.7,.7,1 },
                        xsvg = {
                            path = "ic_location_searching_48px.svg",
                        }
                    },
                    image = {
                        src = "if-twitter-1024.png", -- source image file
                        -- Below is optional if you have buttons on a sheet
                        -- The 'sheetOptions' is directly from Corona sheets
                        sheetIndex = 1, -- which frame to show for image from sheet
                        touchIndex = 2, -- which frame to show for touch event
                        disabledIndex = -1, -- which frame to show when disabled
                        touchFadeAnimation = true, -- helpful with shadows
                        touchFadeAnimationSpeedOut = 500,
                        sheetOptions = {
                            -- The params below are required by Corona

                            width = 512,
                            height = 512,
                            numFrames = 2,

                            -- The params below are optional (used for dynamic image sheet selection)

                            sheetContentWidth = 1024,  -- width of original 1x size of entire sheet
                            sheetContentHeight = 512  -- height of original 1x size of entire sheet

                        }
                    }
                }
            },
            { 
                key = "To-do",
                value = "4",
                icon="view_list",
                --labelText="To-do",
                isActive = false,
                state = {
                    value = "off",
                    off = {
                        textColor = { 1,1,1,1 },
                        strokeColor = { .3,.3,.3,1 },
                        labelColor = { 1,1,1,1 },
                        xsvg = {
                            path = "ic_view_list_48px.svg",
                        }
                    },
                    on = {
                        textColor = { 1,0,0,1 },
                        strokeColor = { .3,.3,.3,1 },
                        labelColor = { 1,0,0,1 },
                        xsvg = {
                            path = "ic_view_list_48px.svg",
                        }
                    },
                    disabled = {
                        textColor = { .7,.7,.7,1 },
                        strokeColor = { .7,.7,.7,1 },
                        labelColor = { .7,.7,.7,1 },
                        xsvg = {
                            path = "ic_view_list_48px.svg",
                        }
                    },
                    image = {
                        src = "if-yahoo-1024.png", -- source image file
                        -- Below is optional if you have buttons on a sheet
                        -- The 'sheetOptions' is directly from Corona sheets
                        sheetIndex = 1, -- which frame to show for image from sheet
                        touchIndex = 2, -- which frame to show for touch event
                        disabledIndex = -1, -- which frame to show when disabled
                        touchFadeAnimation = true, -- helpful with shadows
                        touchFadeAnimationSpeedOut = 500,
                        sheetOptions = {
                            -- The params below are required by Corona

                            width = 512,
                            height = 512,
                            numFrames = 2,

                            -- The params below are optional (used for dynamic image sheet selection)

                            sheetContentWidth = 1024,  -- width of original 1x size of entire sheet
                            sheetContentHeight = 512  -- height of original 1x size of entire sheet

                        }
                    }
                }
            },
            -- { key = "Viewer", value = "4", labelText="View", isActive = false } -- uncomment to see View as text
        }
    })

function sliderCallBackMove( event )
    local muiTarget = mui.getEventParameter(event, "muiTarget")
    local muiTargetValue = mui.getEventParameter(event, "muiTargetValue")

    if event.target ~= nil then
        mui.debug("sliderCallBackMove is: "..muiTargetValue)
    end
    local percent = muiData.widgetDict["slider_demo"]["value"]
    if muiData.widgetDict["slider_demo"]["value"] ~= nil then
        local newAngel = 360 * percent
        transition.to( logo, {rotation = newAngel, time=0} )
    end
end

    mui.newSlider({
        name = "slider_demo",
        width = 200,
        height = 2,
        x = 130,
        y = 230,
        radius = 12,
        colorOff = { 1, 1, 1, 1 },
        color = { 0.63, 0.81, 0.181 },
        startPercent = 30,
        enlargeHandle = false, -- the part that is dragged around
        xbackground = {
            color = { 0.7,.7,.7,0.05}
        },
        state = {
            value = "off"
        },
        handle = {
            off = {
                color = { 0.63, 0.81, 0.181 },
                strokeColor = { 0.63, 0.81, 0.181 },
                image = "knob-gfx.png",
                xsvg = {
                    path = "simple-circle.svg"
                }
            },
            on = {
                color = { 0.63, 0.81, 0.181 },
                strokeColor = { 0.63, 0.81, 0.181 },
                image = "knob-gfx-on.png",
                xsvg = {
                    path = "simple-circle.svg"
                }
            },
            disabled = {
                color = { .3,.3,.3 },
                strokeColor = { .3,.3,.3 },
                ximage = "knob-gfx-disabled.png",
                xsvg = {
                    path = "simple-circle.svg"
                }
            }
        },
        bar = {
            off = {
                color = { 0.63, 0.81, 0.181 },
                strokeColor = { 0.63, 0.81, 0.181 },
                image = "knob-gfx-base.png"
            },
            on = {
                color = { 0.63, 0.81, 0.181 },
                strokeColor = { 0.63, 0.81, 0.181 },
                image = "knob-gfx-base.png"
            },
            disabled = {
                color = { .3,.3,.3 },
                strokeColor = { .3,.3,.3 },
                image = "knob-gfx-base.png"
            }
        },
        callBackMove = sliderCallBackMove,
        callBack = mui.sliderCallBack
    })

    -- create a drop down list
    local numOfRowsToShow = 3
    mui.newSelect({
        name = "selector_demo2",
        labelText = "Favorite Food",
        text = "Apple",
        font = native.systemFont,
        textColor = { 0.4, 0.4, 0.4 },
        fieldBackgroundColor = { 1, 1, 1, 1 },
        rowColor = { default={ 1, 1, 1, 1 }, over={ 1, 0.5, 0, 0.2 } }, -- 0.01 = transparent -- default is the highlighting
        rowBackgroundColor = { 1, 1, 1, 1 }, -- the drop down color of each row
        touchpointColor = { 0.4, 0.4, 0.4 }, -- the touchpoint color
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        strokeColor = { 0.4, 0.4, 0.4, 1 },
        strokeWidth = 2,
        hideBackground = true,
        width = 200,
        height = 30,
        listHeight = 30 * numOfRowsToShow,
        x = 550,
        y = 240,
        callBackTouch = mui.onRowTouchSelector,
        scrollListener = nil,
        list = { -- if 'key' use it for 'id' in the table row
            { key = "Row1", text = "Apple", value = "Apple", isCategory = false, backgroundColor = {1,1,1,1} },
            { key = "Row2", text = "Cookie", value = "Cookie", isCategory = false },
            { key = "Row3", text = "Pizza", value = "Pizza", isCategory = false },
            { key = "Row4", text = "Shake", value = "Shake", isCategory = false },
            { key = "Row5", text = "Shake 2", value = "Shake 2", isCategory = false },
            { key = "Row6", text = "Shake 3", value = "Shake 3", isCategory = false },
            { key = "Row7", text = "Shake 4", value = "Shake 4", isCategory = false },
            { key = "Row8", text = "Shake 5", value = "Shake 5", isCategory = false },
            { key = "Row9", text = "Shake 6", value = "Shake 6", isCategory = false },
        },
        state = {
            value = "off",
            disabled = {
                fieldBackgroundColor = { .7,.7,.7,1 },
                callBack = buttonMessage,
                callBackData = {message = "button is disabled"}
            }
        },
        arrow = {
            off = {
                color = { 0.4, 0.4, 0.4 },
                image = "arrow-down.png",
                xsvg = {
                    fillColor = { .5, .12, .5, 1 },
                    path = "arrow-down.svg"
                }
            },
            disabled = {
                color = { 0.4, 0.4, 0.4 },
                image = "arrow-down.png",
                xsvg = {
                    fillColor = { .3, .3, .3, 1 },
                    path = "arrow-down.svg"
                }
            }
        },
        backgroundFake = {
            off = {
                image = "TextBackground.jpg",
                xsvg = {
                    path = "jigsaw.svg"
                }
            },
            disabled = {
                image = "TextBackground-disabled.jpg",
                xsvg = {
                    path = "jigsaw.svg"
                }
            }
        },  
        background = {
            image = "TextBackground.jpg",
            xsvg = {
                path = "jigsaw.svg"
            }
        },  
        scrollView = scrollView,
    })

    ---[[--
    mui.newTextField({
        name = "textfield_demo4",
        labelText = "My Topic",
        text = "Hello, World!",
        font = native.systemFont,
        width = 200,
        height = 30,
        x = 550,
        y = 100,
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        state = {
            value = "off",
            disabled = {
                fieldBackgroundColor = { .7,.7,.7,1 },
                callBack = buttonMessage,
                callBackData = {message = "button is disabled"}
            }
        },
        backgroundFake = {
            off = {
                image = "TextBackground.jpg",
                xsvg = {
                    path = "jigsaw.svg"
                }
            },
            disabled = {
                image = "TextBackground-disabled.jpg",
                xsvg = {
                    path = "jigsaw.svg"
                }
            }
        },  
        background = {
            image = "TextBackground.jpg",
            xsvg = {
                path = "jigsaw.svg"
            }
        }
    })
    --]]--

    --[[--
    mui.newTextBox({
        name = "textbox_demo1",
        labelText = "Secret Text Box",
        text = "I am hidden in view\nYes, me too!\nFood\nDrink\nDesert\n1\n2\n3\n4\n5",
        font = native.systemFont,
        fontSize = 16,
        textBoxFontSize = 16,
        width = 200,
        height = 100,
        x = 550,
        y = 120,
        trimFakeTextAt = 80, -- trim at 1..79 characters.
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        isEditable = true,
        doneButton = {
            width = 100,
            height = 30,
            fillColor = { 0.25, 0.75, 1, 1 },
            textColor = { 1, 1, 1 },
            text = "done",
            iconText = "done",
            iconFont = mui.materialFont,
            iconFontColor = { 1, 1, 1, 1 },
            radius = mui.getScaleX(8), -- set to 0 for newRectButton() instead of rounded
        },
        overlayBackgroundColor = { 1, 1, 1, 1 },
        overlayTextBoxBackgroundColor = { .9, .9, .9, 1 },
        overlayTextBoxHeight = 100,
        scrollView = scrollView,
        state = {
            value = "off",
            disabled = {
                fieldBackgroundColor = { .7,.7,.7,1 },
                callBack = buttonMessage,
                callBackData = {message = "button is disabled"}
            }
        },
        backgroundFake = {
            off = {
                image = "TextBackground.jpg",
                xsvg = {
                    path = "jigsaw.svg"
                }
            },
            disabled = {
                image = "TextBackground-disabled.jpg",
                xsvg = {
                    path = "jigsaw.svg"
                }
            }
        },  
        background = {
            image = "TextBackground.jpg",
            xsvg = {
                path = "jigsaw.svg"
            }
        }
    })
    --]]--

    -- toggle switch example
    mui.newToggleSwitch({
        parent = mui.getParent(),
        name = "switch_demo",
        size = 40, --40
        x = 540,
        y = 165,
        isChecked = false,
        value = 100, -- if switch is in the on position it's 100 else nil
        callBack = mui.actionForSwitch,
        state = {
            value = "on"
        },
        handle = {
            width = 40,
            height = 40,
            off = {
                color = { 0.57, 0.85, 1, 1 },
                strokeColor = { 0.63, 0.81, 0.181 },
                image = "knob-gfx.png",
                xsvg = {
                    path = "simple-circle.svg"
                }
            },
            on = {
                color = { 0.25, 0.75, 1, 1 },
                strokeColor = { 0.63, 0.81, 0.181 },
                image = "knob-gfx-on.png",
                xsvg = {
                    path = "simple-circle.svg"
                }
            },
            disabled = {
                color = { .7,.7,.7   },
                strokeColor = { .3,.3,.3 },
                image = "knob-gfx-disabled.png",
                xsvg = {
                    path = "simple-circle.svg"
                }
            }
        },
        bar = {
            width = 100,
            height = 20,
            off = {
                color = { 0.82, 0.95, 0.98, 1 },
                strokeColor = { 0.82, 0.95, 0.98, 1 },
                image = "knob-gfx-base.png",
                xsvg = {
                    path = "jigsaw.svg"
                }
            },
            on = {
                color = { 0.74, 0.88, 0.99, 1 },
                strokeColor = { 0.74, 0.88, 0.99, 1 },
                image = "knob-gfx-base.png",
                xsvg = {
                    path = "jigsaw.svg"
                }
            },
            disabled = {
                color = { .5,.5,.5 },
                strokeColor = { .5,.5,.5 },
                image = "knob-gfx-base.png",
                xsvg = {
                    path = "jigsaw.svg"
                }
            }
        }
    })
