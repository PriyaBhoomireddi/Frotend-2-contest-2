var modelType = "QUICK TURN 100-M";
description = "Mazak Quick Turn 100-M";
// >>>>> INCLUDED FROM ../common/mazak mill-turn.cps

//Save This line for editing purposes, comment out before merge
//var modelType = "QUICK TURN 250-M";
//var modelType = "QTU 250-MSY";

/**
  Copyright (C) 2012-2021 by Autodesk, Inc.
  All rights reserved.

  Mazak Quickturn lathe post processor configuration.

  $Revision: 43210 19c74f1ca480db397dd81183356e16eb6fb73149 $
  $Date: 2021-03-01 14:14:53 $

  FORKID {086A02EF-4920-4866-9BB6-2F08579DD109}
*/

///////////////////////////////////////////////////////////////////////////////
//                        MANUAL NC COMMANDS
//
// The following ACTION commands are supported by this post.
//
//     partEject                       - Manually eject the part
//     transferType:phase,speed,stop   - Phase or Speed spindle synchronization for stock-transfer
//     transferUseTorque:yes,no   - Use torque control for stock-transfer
//     useXZCMode                      - Force XZC mode for next operation
//     usePolarMode                    - Force Polar mode for next operation
//
// Note: Enter the Tool ID Code in the Product ID of the Tool. Leave Blank if not used
///////////////////////////////////////////////////////////////////////////////

if (!description) {
  description = "Mazak Quick turn/QTU lathe post processor configuration";
}
vendor = "Mazak";
vendorUrl = "https://www.mazak.com/";
legal = "Copyright (C) 2012-2021 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45702;

if (!longDescription) {
  longDescription = subst("Preconfigured %1 post (Smooth/Matrix/640MT control) with support for mill-turn. Enter the Tool ID Code in the Product ID of the Tool. Leave Blank if not used", description);
}

extension = "EIA";
programNameIsInteger = true;
setCodePage("ascii");
capabilities = CAPABILITY_MILLING | CAPABILITY_TURNING;

tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.01, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(120); // reduced sweep due to G112 support
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion
allowSpiralMoves = false;
highFeedrate = (unit == IN) ? 470 : 12000;

// user-defined properties
properties = {
  writeMachine: {
    title: "Write machine",
    description: "Output the machine settings in the header of the code.",
    group: 0,
    type: "boolean",
    value: false,
    scope: "post"
  },
  writeTools: {
    title: "Write tool list",
    description: "Output a tool list in the header of the code.",
    group: 0,
    type: "boolean",
    value: false,
    scope: "post"
  },
  maxTool: {
    title: "Max tool number",
    description: "Defines the maximum tool number.",
    type: "integer",
    range: [0, 999999999],
    value: 24,
    scope: "post"
  },
  showSequenceNumbers: {
    title: "Use sequence numbers",
    description: "Use sequence numbers for each block of outputted code.",
    group: 1,
    type: "boolean",
    value: true,
    scope: "post"
  },
  sequenceNumberStart: {
    title: "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group: 1,
    type: "integer",
    value: 1,
    scope: "post"
  },
  sequenceNumberIncrement: {
    title: "Sequence number increment",
    description: "The amount by which the sequence number is incremented by in each block.",
    group: 1,
    type: "integer",
    value: 1,
    scope: "post"
  },
  sequenceNumberToolOnly: {
    title: "Sequence numbers only on tool change",
    description: "Output sequence numbers on tool changes instead of every line.",
    group: 1,
    type: "boolean",
    value: true,
    scope: "post"
  },
  optionalStop: {
    title: "Optional stop",
    description: "Outputs optional stop code during when necessary in the code.",
    group: 1,
    type: "boolean",
    value: true,
    scope: "post"
  },
  separateWordsWithSpace: {
    title: "Separate words with space",
    description: "Adds spaces between words if 'yes' is selected.",
    group: 1,
    type: "boolean",
    value: true,
    scope: "post"
  },
  useRadius: {
    title: "Radius arcs",
    description: "If yes is selected, arcs are outputted using radius values rather than IJK.",
    group: 1,
    type: "boolean",
    value: true,
    scope: "post"
  },
  maximumSpindleSpeed: {
    title: "Max spindle speed",
    description: "Defines the maximum spindle speed allowed by your machines.",
    group: 1,
    type: "integer",
    range: [0, 999999999],
    value: 6000,
    scope: "post"
  },
  useParametricFeed: {
    title: "Parametric feed",
    description: "Specifies the feed value that should be output using a Q value.",
    group: 1,
    type: "boolean",
    value: false,
    scope: "post"
  },
  showNotes: {
    title: "Show notes",
    description: "Writes operation notes as comments in the outputted code.",
    group: 1,
    type: "boolean",
    value: false,
    scope: "post"
  },
  useCycles: {
    title: "Use cycles",
    description: "Specifies if canned drilling cycles should be used.",
    group: 1,
    type: "boolean",
    value: true,
    scope: "post"
  },
  gotPartCatcher: {
    title: "Use part catcher",
    description: "Specifies whether part catcher code should be output.",
    group: 1,
    type: "boolean",
    value: true,
    scope: "post"
  },
  autoEject: {
    title: "Auto eject",
    description: "Specifies whether the part should automatically eject at the end of a program.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  useTailStock: {
    title: "Use tailstock",
    description: "Specifies whether to use the tailstock or not.",
    group: 1,
    type: "boolean",
    presentation: "yesno",
    value: false,
    scope: "post"
  },
  useG53Zhome: {
    title: "Use G53 Z home",
    description: "Specifies whether to use a G53 Z home position.",
    group: 1,
    type: "boolean",
    presentation: "yesno",
    value: true,
    scope: "post"
  },
  zHomePosition: {
    title: "Z home position",
    description: "Z home position, only output if Use G53 Z Home is not used.",
    group: 1,
    type: "number",
    value: 0,
    scope: "post"
  },
  transferType: {
    title: "Transfer type",
    description: "Phase, speed synchronization for stock-transfer.",
    group: 1,
    type: "enum",
    values: [
      "Phase",
      "Speed"
    ],
    value: "Phase",
    scope: "post"
  },
  transferTool: {
    title: "Transfer Tool Number",
    description: "Defines the tool called when secondary spindle chuck process happens",
    group: 1,
    type: "number",
    range: [0, 999999999],
    value: 1212.01,
    scope: "post"
  },
  optimizeCaxisSelect: {
    title: "Optimize C axis selection",
    description: "Optimizes the output of enable/disable C-axis codes.",
    group: 1,
    type: "boolean",
    value: false,
    scope: "post"
  },
  transferUseTorque: {
    title: "Stock-transfer torque control",
    description: "Use torque control for stock transfer.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  looping: {
    title: "Use M98 looping",
    description: "Output program for M98 looping.",
    type: "boolean",
    presentation: "yesno",
    value: false,
    scope: "post"
  },
  numberOfRepeats: {
    title: "Number of repeats",
    description: "How many times to loop the program.",
    type: "integer",
    range: [0, 99999999],
    value: 1,
    scope: "post"
  },
  writeVersion: {
    title: "Write version",
    description: "Write the version number in the header of the code.",
    group: 0,
    type: "boolean",
    value: false,
    scope: "post"
  },
  useRigidTapping: {
    title: "Use rigid tapping",
    description: "Select 'Yes' to enable, 'No' to disable.",
    type: "boolean",
    value: true,
    scope: "post"
  },
  useSimpleThread: {
    title: "Use simple threading cycle",
    description: "Enable to output G92 simple threading cycle, disable to output G76 standard threading cycle.",
    group: 1,
    type: "boolean",
    value: true,
    scope: "post"
  },
  useYAxisForDrilling: {
    title: "Position in Y for axial drilling",
    description: "Positions in Y for axial drilling options when it can instead of using the C-axis.",
    type: "boolean",
    value: false,
    scope: "post"
  },
  isoModeOrMazatrol: {
    title: "Use ISO Tool Table or Mazatrol",
    description: "Switch for using Maztrol subprogram, tool table and work offsets or full ISO",
    group: 2,
    type: "enum",
    values: [
      "ISO",
      "Mazatrol"
    ],
    value: "Mazatrol",
    scope: "post"
  },
  controllerType: {
    title: "Version of Controller",
    description: "Switch for using a Fusion or Matrix controller",
    type: "enum",
    group: 2,
    values: [
      "640MT",
      "Matrix",
      "Smooth"
    ],
    value: "Matrix",
    scope: "post"
  }
};

var permittedCommentChars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,=_-";

var gFormat = createFormat({prefix:"G", decimals:1});
var g1Format = createFormat({prefix:"G", decimals:1});
var mFormat = createFormat({prefix:"M", decimals:0});

var spatialFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var xFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true, scale:2}); // diameter mode & IS SCALING POLAR COORDINATES
var yFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var zFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var subBFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true, forceSign:true});
var rFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true}); // radius
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var cFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG, cyclicLimit:Math.PI * 2});
var feedFormat = createFormat({decimals:(unit == MM ? 2 : 3), forceDecimal:true});
var pitchFormat = createFormat({decimals:6, forceDecimal:true});
var toolFormat = createFormat({decimals:0, width:4, zeropad:true});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-99999.999
var milliFormat = createFormat({decimals:0}); // milliseconds // range 1-9999
var taperFormat = createFormat({decimals:1, scale:DEG});
var qFormat = createFormat({decimals:0, forceDecimal:false, trim:false, width:4, zeropad:true, scale:10000});
var threadP1Format = createFormat({decimals:0, forceDecimal:false, trim:false, width:6, zeropad:true});
var threadPQFormat = createFormat({decimals:0, forceDecimal:false, trim:true, scale:10000});
var dwellFormat = createFormat({prefix:"U", decimals:3});

var xOutput = createVariable({prefix:"X"}, xFormat);
var yOutput = createVariable({prefix:"Y"}, yFormat);
var zOutput = createVariable({prefix:"Z"}, zFormat);
var subBOutput = createVariable({prefix:"B[#501", force:true}, subBFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, cFormat);
var barOutput = createVariable({prefix:"B", force:true}, spatialFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var pitchOutput = createVariable({prefix:"F", force:true}, pitchFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var pOutput = createVariable({prefix:"P", force:true}, rpmFormat);
var rcssOutput = createVariable({prefix:"R", force:true}, rpmFormat);
var qOutput = createVariable({prefix:"Q", force:true}, qFormat);
var rOutput = createVariable({prefix:"R", force:true}, rFormat);
var threadP1Output = createVariable({prefix:"P", force:true}, threadP1Format);
var threadP2Output = createVariable({prefix:"P", force:true}, threadPQFormat);
var threadQOutput = createVariable({prefix:"Q", force:true}, threadPQFormat);
var threadROutput = createVariable({prefix:"R", force:true}, threadPQFormat);
var threadIOutput = createVariable({prefix:"I", force:true}, threadPQFormat);

// circular output
var iOutput = createReferenceVariable({prefix:"I", force:true}, spatialFormat);
var jOutput = createReferenceVariable({prefix:"J", force:true}, spatialFormat);
var kOutput = createReferenceVariable({prefix:"K", force:true}, spatialFormat);

var g92ROutput = createVariable({prefix:"R", force:true}, zFormat); // no scaling

var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G98-99
var gSpindleModeModal = createModal({}, gFormat); // modal group 5 // G96-97
var gSpindleModal = createModal({}, mFormat); // M176/177 SPINDLE MODE
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({}, gFormat); // modal group 9 // G81, ...
var gPolarModal = createModal({}, g1Format); // G12.1, G13.1
var gSelectSpindleModal = createModal({}, mFormat); // G141, G142
var cAxisEngageModal = createModal({}, mFormat);
var cAxisBrakeModal = createModal({}, mFormat);
var mInterferModal = createModal({}, mFormat);
var gotPolarInterpolation;
var maximumSpindleSpeedLive;
var gotSecondarySpindle;
var gotYAxis;
// fixed settings
var firstFeedParameter = 100;

var gotDoorControl = false;
var useG31push = false;
var airCleanChuck = false; // use air to clean off chuck at part transfer and part eject

var WARNING_WORK_OFFSET = 0;
var WARNING_REPEAT_TAPPING = 1;

var SPINDLE_MAIN = 0;
var SPINDLE_SUB = 1;
var SPINDLE_LIVE = 2;

var POSX = 0;
var POXY = 1;
var POSZ = 2;
var NEGZ = -2;

var TRANSFER_PHASE = 0;
var TRANSFER_SPEED = 1;
var TRANSFER_STOP = 2;

// collected state
var sequenceNumber;
var currentWorkOffset;
var optionalSection = false;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var previousSpindle = SPINDLE_MAIN;
var previousPartSpindle = SPINDLE_MAIN;
var activeSpindle = SPINDLE_MAIN;
var partCutoff = false;
var transferType;
var transferUseTorque;
var showSequenceNumbers;
var stockTransferIsActive = false;
var forceXZCMode = false; // forces XZC output, activated by Action:useXZCMode
var forcePolarMode = false; // force Polar output, activated by Action:usePolarMode
var tapping = false;
var ejectRoutine = false;
var bestABCIndex = undefined;

var machineState = {
  liveToolIsActive: undefined,
  cAxisIsEngaged: undefined,
  machiningDirection: undefined,
  mainSpindleIsActive: undefined,
  subSpindleIsActive: undefined,
  mainSpindleBrakeIsActive: undefined,
  subSpindleBrakeIsActive: undefined,
  tailstockIsActive: undefined,
  usePolarMode: undefined,
  useXZCMode: undefined,
  axialCenterDrilling: undefined,
  currentBAxisOrientationTurning: new Vector(0, 0, 0)
};

function getCode(code, spindle) {
  switch (code) {
  case "PART_CATCHER_ON":
    return 48;
  case "PART_CATCHER_OFF":
    return 49;
  case "TAILSTOCK_ON":
    machineState.tailstockIsActive = true;
    return mFormat.format(741);
  case "TAILSTOCK_OFF":
    machineState.tailstockIsActive = false;
    return mFormat.format(743);
  case "ENABLE_C_AXIS":
    machineState.cAxisIsEngaged = true;
    return (spindle == SPINDLE_MAIN) ? 200 : 300;
  case "DISABLE_C_AXIS":
    machineState.cAxisIsEngaged = false;
    return (spindle == SPINDLE_MAIN) ? 202 : 302;
  case "POLAR_INTERPOLATION_ON":
    return 12.1;
  case "POLAR_INTERPOLATION_OFF":
    return 13.1;
  case "STOP_SPINDLE":
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = false;
      return 5;
    case SPINDLE_SUB:
      machineState.subSpindleIsActive = false;
      return 305;
    case SPINDLE_LIVE:
      machineState.liveToolIsActive = false;
      return 205;
    }
    break;
  case "ORIENT_SPINDLE":
    return (spindle == SPINDLE_MAIN) ? 19 : 39;
  case "START_SPINDLE_CW":
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = true;
      return 3;
    case SPINDLE_SUB:
      machineState.subSpindleIsActive = true;
      return 303;
    case SPINDLE_LIVE:
      machineState.liveToolIsActive = true;
      return 203;
    }
    break;
  case "START_SPINDLE_CCW":
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = true;
      return 4;
    case SPINDLE_SUB:
      machineState.subSpindleIsActive = true;
      return 304;
    case SPINDLE_LIVE:
      machineState.liveToolIsActive = true;
      return 204;
    }
    break;
  case "FEED_MODE_MM_REV":
    return 99;
  case "FEED_MODE_MM_MIN":
    return 98;
  case "CONSTANT_SURFACE_SPEED_ON":
    return 96;
  case "CONSTANT_SURFACE_SPEED_OFF":
    return 97;
  case "LOCK_MULTI_AXIS":
    return (spindle == SPINDLE_MAIN) ? 210 : 310;
  case "UNLOCK_MULTI_AXIS":
    return (spindle == SPINDLE_MAIN) ? 212 : 312;
  case "CLAMP_CHUCK":
    return (spindle == SPINDLE_MAIN) ? 207 : 307;
  case "UNCLAMP_CHUCK":
    return (spindle == SPINDLE_MAIN) ? 206 : 306;
  case "SPINDLE_SYNCHRONIZATION_PHASE":
    return 511;
  case "SPINDLE_SYNCHRONIZATION_PHASE_OFF":
    return 513;
  case "SPINDLE_SYNCHRONIZATION_SPEED":
    return 380;
  case "SPINDLE_SYNCHRONIZATION_SPEED_OFF":
    return 381;
  case "TORQUE_SKIP_ON":
    return 508;
  case "TORQUE_SKIP_OFF":
    return 509;
  case "ACTIVATE_SPINDLE":
    return (spindle == SPINDLE_MAIN) ? 901 : 902;
  case "SELECT_SPINDLE":
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = true;
      machineState.subSpindleIsActive = false;
      machineState.liveToolIsActive = false;
      return 1;
    /*case SPINDLE_LIVE:
      machineState.mainSpindleIsActive = false;
      machineState.subSpindleIsActive = false;
      machineState.liveToolIsActive = true;
      return false;
      */
    case SPINDLE_SUB:
      machineState.mainSpindleIsActive = false;
      machineState.subSpindleIsActive = true;
      machineState.liveToolIsActive = false;
      return 2;
    }
    break;
  case "RIGID_TAPPING":
    return 29;
  case "INTERLOCK_BYPASS":
    return 31;
  case "INTERLOCK_BYPASS_OFF":
    return 32;
    /*
  case "INTERFERENCE_CHECK_OFF":
    return 110;
  case "INTERFERENCE_CHECK_ON":
    return 111;
*/
  case "CYCLE_PART_EJECTOR":
    return 185;
  // coolant codes
  case "COOLANT_FLOOD_ON":
    return 8;
  case "COOLANT_FLOOD_OFF":
    return 9;
  case "COOLANT_AIR_ON":
    return (spindle == SPINDLE_MAIN) ? 26 : 36;
  case "COOLANT_AIR_OFF":
    return (spindle == SPINDLE_MAIN) ? 27 : 37;
  case "COOLANT_THROUGH_TOOL_ON":
    return 7;
  case "COOLANT_THROUGH_TOOL_OFF":
    return 9;
  case "COOLANT_OFF":
    return 9;
  default:
    error(localize("Command " + code + " is not defined."));
    return 0;
  }
  return 0;
}
function getmachinetype() {
  if (modelType == "QUICK TURN 100-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 100-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 100-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 100-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 200-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 200-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 200-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 200-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 250-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 250-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 250-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 250-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 10000;
  } else if (modelType == "QUICK TURN 350-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QUICK TURN 350-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -76.2 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 76.2 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QUICK TURN 350-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -76.2 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 76.2 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QUICK TURN 400-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QUICK TURN 450-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QUICK TURN 450-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -101.6 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 101.6 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 6000;
  } else if (modelType == "QTU 200-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 200-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 200-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 200-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 250-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 250-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 250-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 250-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 350-M") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 350-MS") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = false;
    yAxisMinimum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 0 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 350-MSY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = true;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  } else if (modelType == "QTU 350-MY") {
    gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
    gotSecondarySpindle = false;
    gotYAxis = true;
    yAxisMinimum = toPreciseUnit(gotYAxis ? -50 : 0, MM); // specifies the minimum range for the Y-axis
    yAxisMaximum = toPreciseUnit(gotYAxis ? 50 : 0, MM); // specifies the maximum range for the Y-axis
    xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
    gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
    gotMultiTurret = false; // specifies if the machine has several turrets
    maximumSpindleSpeedLive = 4500;
  }
}

/** Returns the modulus. */
function getModulus(x, y) {
  return Math.sqrt(x * x + y * y);
}

/**
  Returns the C rotation for the given X and Y coordinates.
*/
function getC(x, y) {
  var direction;
  if (Vector.dot(machineConfiguration.getAxisU().getAxis(), new Vector(0, 0, 1)) != 0) {
    direction = (machineConfiguration.getAxisU().getAxis().getCoordinate(2) >= 0) ? 1 : -1; // C-axis is the U-axis
  } else {
    direction = (machineConfiguration.getAxisV().getAxis().getCoordinate(2) >= 0) ? 1 : -1; // C-axis is the V-axis
  }
  return Math.atan2(y, x) * direction;
}

/**
  Returns the C rotation for the given X and Y coordinates in the desired rotary direction.
*/
function getCClosest(x, y, _c, clockwise) {
  if (_c == Number.POSITIVE_INFINITY) {
    _c = 0; // undefined
  }
  if (!xFormat.isSignificant(x) && !yFormat.isSignificant(y)) { // keep C if XY is on center
    return _c;
  }
  var c = getC(x, y);
  if (clockwise != undefined) {
    if (clockwise) {
      while (c < _c) {
        c += Math.PI * 2;
      }
    } else {
      while (c > _c) {
        c -= Math.PI * 2;
      }
    }
  } else {
    min = _c - Math.PI;
    max = _c + Math.PI;
    while (c < min) {
      c += Math.PI * 2;
    }
    while (c > max) {
      c -= Math.PI * 2;
    }
  }
  return c;
}

/**
  Returns the desired tolerance for the given section.
*/
function getTolerance() {
  var t = tolerance;
  if (hasParameter("operation:tolerance")) {
    if (t > 0) {
      t = Math.min(t, getParameter("operation:tolerance"));
    } else {
      t = getParameter("operation:tolerance");
    }
  }
  return t;
}

function formatSequenceNumber() {
  if (sequenceNumber > 99999) {
    sequenceNumber = getProperty("sequenceNumberStart");
  }
  var seqno = "N" + sequenceNumber;
  sequenceNumber += getProperty("sequenceNumberIncrement");
  return seqno;
}

/**
  Writes the specified block.
*/
function writeBlock() {
  var seqno = "";
  var opskip = "";
  if (showSequenceNumbers) {
    seqno = formatSequenceNumber();
  }
  if (optionalSection) {
    opskip = "/";
  }
  var text = formatWords(arguments);
  if (text) {
    writeWords(opskip, seqno, text);
  }
}

function writeDebug(_text) {
  writeComment("DEBUG - " + _text);
}

function formatComment(text) {
  return "(" + String(filterText(String(text).toUpperCase(), permittedCommentChars)).replace(/[()]/g, "") + ")";
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text));
}

function getB(abc, section) {
  if (section.spindle == SPINDLE_PRIMARY) {
    return abc.y;
  } else {
    return Math.PI - abc.y;
  }
}

function writeCommentSeqno(text) {
  writeln(formatSequenceNumber() + formatComment(text));
}

var machineConfigurationMainSpindle;
var machineConfigurationSubSpindle;

var machineConfigurationZ;
var machineConfigurationXC;
var machineConfigurationXB;

function onOpen() {
  getmachinetype();
  if (getProperty("useRadius")) {
    maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
  }

  // Copy certain properties into global variables
  showSequenceNumbers = getProperty("sequenceNumberToolOnly") ? false : getProperty("showSequenceNumbers");
  transferType = parseToggle(getProperty("transferType"), "PHASE", "SPEED");
  if (transferType == undefined) {
    error(localize("TransferType must be Phase or Speed"));
    return;
  }
  transferUseTorque = getProperty("transferUseTorque");
  // Setup default M-codes
  // mInterferModal.format(getCode("INTERFERENCE_CHECK_ON", SPINDLE_MAIN));

  if (true) {
    var bAxisMain = createAxis({coordinate:1, table:false, axis:[0, -1, 0], range:[-0.001, 90.001], preference:0});
    var cAxisMain = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0}); // C axis is modal between primary and secondary spindle

    var bAxisSub = createAxis({coordinate:1, table:false, axis:[0, -1, 0], range:[-0.001, 180.001], preference:0});
    var cAxisSub = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0}); // C axis is modal between primary and secondary spindle

    machineConfigurationMainSpindle = gotBAxis ? new MachineConfiguration(bAxisMain, cAxisMain) : new MachineConfiguration(cAxisMain);
    machineConfigurationSubSpindle =  gotBAxis ? new MachineConfiguration(bAxisSub, cAxisSub) : new MachineConfiguration(cAxisSub);
  }

  machineConfiguration = new MachineConfiguration(); // creates an empty configuration to be able to set eg vendor information
  
  machineConfiguration.setVendor("Mazak");
  machineConfiguration.setModel("QuickTurn");
  
  if (!gotYAxis) {
    yOutput.disable();
  }
  aOutput.disable();
  if (!gotBAxis) {
    bOutput.disable();
  }

  if (highFeedrate <= 0) {
    error(localize("You must set 'highFeedrate' because axes are not synchronized for rapid traversal."));
    return;
  }

  if (!getProperty("separateWordsWithSpace")) {
    setWordSeparator("");
  }

  sequenceNumber = getProperty("sequenceNumberStart");

  if (programName) {
    var programId;
    try {
      programId = getAsInt(programName);
    } catch (e) {
      error(localize("Program name must be a number."));
      return;
    }
    if (!((programId >= 1) && (programId <= 9999))) {
      error(localize("Program number is out of range."));
      return;
    }
    var oFormat = createFormat({width:4, zeropad:true, decimals:0});
    if (programComment) {
      writeln("(O" + oFormat.format(programId) + " -" + filterText(String(programComment).toUpperCase(), permittedCommentChars) + ")");
    } else {
      writeln("(O" + oFormat.format(programId) + ")");
    }
  } else {
    error(localize("Program name has not been specified."));
    return;
  }

  if (getProperty("isoModeOrMazatrol") == "ISO") {
    writeComment("Check F93 bit 3 is 0 and F94 bit 7 is 0 to use ISO Work Offsets and Tool table");
  } else {
    writeComment("Check F93 bit 3 is 1 and F94 bit 7 is 1 to use Mazatrol Work Offsets and Tool table");
    writeComment("Enter the Tool ID Code in the Product ID of the Tool. Leave Blank if not used");

    if (gotSecondarySpindle) {
      writeBlock("#150=0", formatComment("ENTER DISTANCE FROM SUB ORIGIN TO MAIN ORIGIN. USED TO SHIFT ORIGIN FOR WORKING ON SUB"));
      writeBlock("#501=0", formatComment("Enter the Distance from face of the Part on the Main Spindle to the Face of the Jaws on the Sub Spindle"));
    }
  }
 
  if (getProperty("writeVersion")) {
    if ((typeof getHeaderVersion == "function") && getHeaderVersion()) {
      writeComment(localize("post version") + ": " + getHeaderVersion());
    }
    if ((typeof getHeaderDate == "function") && getHeaderDate()) {
      writeComment(localize("post modified") + ": " + getHeaderDate());
    }
  }

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var description = machineConfiguration.getDescription();

  if (getProperty("writeMachine") && (vendor || model || description)) {
    writeComment(localize(" Machine"));
    if (vendor) {
      writeComment(" " + localize("vendor") + "- " + vendor);
    }
    if (model) {
      writeComment(" " + localize("model") + "- " + modelType);
    }
    if (description) {
      writeComment(" " + localize("description") + "- "  + description);
    }
    writeComment(" " + localize("Controller Type - " + getProperty("controllerType")));
    writeComment(" " + localize("Running in " + getProperty("isoModeOrMazatrol") + " Mode"));
  }
  
  // dump tool information
  if (getProperty("writeTools")) {
    var zRanges = {};
    if (is3D()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var zRange = section.getGlobalZRange();
        var tool = section.getTool();
        if (zRanges[tool.number]) {
          zRanges[tool.number].expandToRange(zRange);
        } else {
          zRanges[tool.number] = zRange;
        }
      }
    }

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var compensationOffset = tool.isTurningTool() ? tool.compensationOffset : tool.lengthOffset;
        var comment = "T" + toolFormat.format(tool.number * 100 + compensationOffset % 100) + " " +
          "D=" + spatialFormat.format(tool.diameter) + " " +
          localize("CR") + "=" + spatialFormat.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
        }
        if (zRanges[tool.number]) {
          comment += " - " + localize("ZMIN") + "=" + spatialFormat.format(zRanges[tool.number].getMinimum());
        }
        comment += " - " + getToolTypeName(tool.type);
        writeComment(comment);
      }
    }
  }

  if (false) {
    // check for duplicate tool number
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var sectioni = getSection(i);
      var tooli = sectioni.getTool();
      for (var j = i + 1; j < getNumberOfSections(); ++j) {
        var sectionj = getSection(j);
        var toolj = sectionj.getTool();
        if (tooli.number == toolj.number) {
          if (spatialFormat.areDifferent(tooli.diameter, toolj.diameter) ||
              spatialFormat.areDifferent(tooli.cornerRadius, toolj.cornerRadius) ||
              abcFormat.areDifferent(tooli.taperAngle, toolj.taperAngle) ||
              (tooli.numberOfFlutes != toolj.numberOfFlutes)) {
            error(
              subst(
                localize("Using the same tool number for different cutter geometry for operation '%1' and '%2'."),
                sectioni.hasParameter("operation-comment") ? sectioni.getParameter("operation-comment") : ("#" + (i + 1)),
                sectionj.hasParameter("operation-comment") ? sectionj.getParameter("operation-comment") : ("#" + (j + 1))
              )
            );
            return;
          }
        }
      }
    }
  }
  
  // support program looping for bar work
  if (getProperty("looping")) {
    if (getProperty("numberOfRepeats") < 1) {
      error(localize("numberOfRepeats must be greater than 0."));
      return;
    }
    if (sequenceNumber == 1) {
      sequenceNumber++;
    }
    writeln("");
    writeln("");
    writeComment(localize("Local Looping"));
    writeln("");
    writeBlock(mFormat.format(98), "Q1", "L" + getProperty("numberOfRepeats"));
    onCommand(COMMAND_OPEN_DOOR);
    writeBlock(mFormat.format(30));
    writeln("");
    writeln("");
    writeln("N1 (START MAIN PROGRAM)");
  }

  writeBlock(gPlaneModal.format(18), gFormat.format(40), gFormat.format(80), gFeedModeModal.format(99));
  goHome();

  onCommand(COMMAND_CLOSE_DOOR);
  
  // automatically eject part at end of program
  if (getProperty("autoEject")) {
    ejectRoutine = true;
  }
}

function onComment(message) {
  writeComment(message);
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
  previousDPMFeed = 0;
  feedOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

function forceUnlockMultiAxis() {
  cAxisBrakeModal.reset();
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  this.feed = feed;
}

function getFeed(f) {
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!feedFormat.areDifferent(feedContext.feed, f)) {
        if (feedContext.id == currentFeedId) {
          return ""; // nothing has changed
        }
        forceFeed();
        currentFeedId = feedContext.id;
        return "F#" + (firstFeedParameter + feedContext.id);
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  return feedOutput.format(f); // use feed value
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();
  var feedPerRev = currentSection.feedMode == FEED_PER_REVOLUTION;

  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }

  if (hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var finishFeedrateRel;
      if (hasParameter("operation:finishFeedrateRel")) {
        finishFeedrateRel = getParameter("operation:finishFeedrateRel");
      } else if (hasParameter("operation:finishFeedratePerRevolution")) {
        finishFeedrateRel = getParameter("operation:finishFeedratePerRevolution");
      }
      var feedContext = new FeedContext(id, localize("Finish"), feedPerRev ? finishFeedrateRel : getParameter("operation:finishFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), feedPerRev ? getParameter("operation:tool_feedEntryRel") : getParameter("operation:tool_feedEntry"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), feedPerRev ? getParameter("operation:tool_feedExitRel") : getParameter("operation:tool_feedExit"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), feedPerRev ? getParameter("operation:noEngagementFeedrateRel") : getParameter("operation:noEngagementFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting") &&
             hasParameter("operation:tool_feedEntry") &&
             hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(
        id,
        localize("Direct"),
        Math.max(
          feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"),
          feedPerRev ? getParameter("operation:tool_feedEntryRel") : getParameter("operation:tool_feedEntry"),
          feedPerRev ? getParameter("operation:tool_feedExitRel") : getParameter("operation:tool_feedExit")
        )
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), feedPerRev ? getParameter("operation:reducedFeedrateRel") : getParameter("operation:reducedFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), feedPerRev ? getParameter("operation:tool_feedRampRel") : getParameter("operation:tool_feedRamp"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedPlunge")) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(id, localize("Plunge"), feedPerRev ? getParameter("operation:tool_feedPlungeRel") : getParameter("operation:tool_feedPlunge"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }
  if (true) { // high feed
    if (movements & (1 << MOVEMENT_HIGH_FEED)) {
      var feedContext = new FeedContext(id, localize("High Feed"), this.highFeedrate);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
    }
    ++id;
  }

  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("#" + (firstFeedParameter + feedContext.id) + "=" + feedFormat.format(feedContext.feed), formatComment(feedContext.description));
  }
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function setWorkPlane(abc) {
  // milling only

  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }

  if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z))) {
    return; // no change
  }

  onCommand(COMMAND_UNLOCK_MULTI_AXIS);

  writeBlock(
    gMotionModal.format(0),
    conditional(machineConfiguration.isMachineCoordinate(0), aOutput.format(abc.x)),
    conditional(machineConfiguration.isMachineCoordinate(1), bOutput.format(abc.y)),
    conditional(machineConfiguration.isMachineCoordinate(2), cOutput.format(abc.z))
  );

  onCommand(COMMAND_LOCK_MULTI_AXIS);

  currentWorkPlaneABC = abc;
  previousABC = abc;
}

function getBestABCIndex(section) {
  var fitFlag = false;
  var index = undefined;
  for (var i = 0; i < 6; ++i) {
    fitFlag = doesToolpathFitInXYRange(getBestABC(section, section.workPlane, i));
    if (fitFlag) {
      index = i;
      break;
    }
  }
  return index;
}

function getBestABC(section, workPlane, which) {
  var W = workPlane;
  var abc = machineConfiguration.getABC(W);
  if (which == undefined) { // turning, XZC, Polar modes
    return abc;
  }
  if (Vector.dot(machineConfiguration.getAxisU().getAxis(), new Vector(0, 0, 1)) != 0) {
    var axis = machineConfiguration.getAxisU(); // C-axis is the U-axis
  } else {
    var axis = machineConfiguration.getAxisV(); // C-axis is the V-axis
  }
  if (axis.isEnabled() && axis.isTable()) {
    var ix = axis.getCoordinate();
    var rotAxis = axis.getAxis();
    if (isSameDirection(machineConfiguration.getDirection(abc), rotAxis) ||
        isSameDirection(machineConfiguration.getDirection(abc), Vector.product(rotAxis, -1))) {
      var direction = isSameDirection(machineConfiguration.getDirection(abc), rotAxis) ? 1 : -1;
      var box = section.getGlobalBoundingBox();
      switch (which) {
      case 1:
        x = box.lower.x + ((box.upper.x - box.lower.x) / 2);
        y = box.lower.y + ((box.upper.y - box.lower.y) / 2);
        break;
      case 2:
        x = box.lower.x;
        y = box.lower.y;
        break;
      case 3:
        x = box.upper.x;
        y = box.lower.y;
        break;
      case 4:
        x = box.upper.x;
        y = box.upper.y;
        break;
      case 5:
        x = box.lower.x;
        y = box.upper.y;
        break;
      default:
        var R = machineConfiguration.getRemainingOrientation(abc, W);
        x = R.right.x;
        y = R.right.y;
        break;
      }
      abc.setCoordinate(ix, getCClosest(x, y, cOutput.getCurrent()));
    }
  }
  // writeComment("Which = " + which + "  Angle = " + abc.z)
  return abc;
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(section, workPlane) {
  var W = workPlane; // map to global frame

  var abc;
  if (machineState.isTurningOperation && gotBAxis) {
    var both = machineConfiguration.getABCByDirectionBoth(workPlane.forward);
    abc = both[0];
    if (both[0].z != 0) {
      abc = both[1];
    }
  } else {
    abc = getBestABC(section, workPlane, bestABCIndex);
    if (closestABC) {
      if (currentMachineABC) {
        abc = machineConfiguration.remapToABC(abc, currentMachineABC);
      } else {
        abc = machineConfiguration.getPreferredABC(abc);
      }
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  }

  try {
    abc = machineConfiguration.remapABC(abc);
    currentMachineABC = abc;
  } catch (e) {
    error(
      localize("Machine angles not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + cFormat.format(abc.z))
    );
    return abc;
  }

  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize("Orientation not supported."));
    return abc;
  }

  if (machineState.isTurningOperation && gotBAxis) { // remapABC can change the B-axis orientation
    if (abc.z != 0) {
      error(localize("Could not calculate a B-axis turning angle within the range of the machine."));
      return abc;
    }
  }

  if (!machineConfiguration.isABCSupported(abc)) {
    error(
      localize("Work plane is not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + cFormat.format(abc.z))
    );
    return abc;
  }

  var tcp = false;
  if (tcp) {
    setRotation(W); // TCP mode
  } else {
    var O = machineConfiguration.getOrientation(abc);
    var R = machineConfiguration.getRemainingOrientation(abc, W);
    setRotation(R);
  }

  return abc;
}

function getBAxisOrientationTurning(section) {
  // THIS CODE IS NOT TESTED.
  var toolAngle = hasParameter("operation:tool_angle") ? getParameter("operation:tool_angle") : 0;
  var toolOrientation = section.toolOrientation;
  if (toolAngle && toolOrientation != 0) {
    error(localize("You cannot use tool angle and tool orientation together in operation " + "\"" + (getParameter("operation-comment")) + "\""));
  }

  var angle = toRad(toolAngle) + toolOrientation;

  var axis = new Vector(0, 1, 0);
  var mappedAngle = (currentSection.spindle == SPINDLE_PRIMARY ? (Math.PI / 2 - angle) : (Math.PI / 2 - angle));
  var mappedWorkplane = new Matrix(axis, mappedAngle);
  var abc = getWorkPlaneMachineABC(mappedWorkplane);

  return abc;
}

function getSpindle(partSpindle) {
  // safety conditions
  if (getNumberOfSections() == 0) {
    return SPINDLE_MAIN;
  }
  if (getCurrentSectionId() < 0) {
    if (machineState.liveToolIsActive && !partSpindle) {
      return SPINDLE_LIVE;
    } else {
      return getSection(getNumberOfSections() - 1).spindle;
    }
  }

  // Turning is active or calling routine requested which spindle part is loaded into
  if (machineState.isTurningOperation || machineState.axialCenterDrilling || partSpindle) {
    return currentSection.spindle;
  //Milling is active
  } else {
    return SPINDLE_LIVE;
  }
}

function getSecondarySpindle() {
  var spindle = getSpindle(true);
  return (spindle == SPINDLE_MAIN) ? SPINDLE_SUB : SPINDLE_MAIN;
}

function getSpindleAxis() {
  if (getSpindle(false) != SPINDLE_LIVE) {
    return POSX;
  }
  if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
    return POSZ;
  } else if (isPerpto(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
    return POSX;
  } else {
    error(localize("Work plane must be Positive-X or Positive-Z."));
    return -1;
  }
}

function isPerpto(a, b) {
  return Math.abs(Vector.dot(a, b)) < (1e-7);
}

function setSpindleOrientationTurning(section) {
  var J; // cutter orientation
  var R; // cutting quadrant
  var leftHandTool = (hasParameter("operation:tool_hand") && (getParameter("operation:tool_hand") == "L" || getParameter("operation:tool_holderType") == 0));
  if (hasParameter("operation:machineInside")) {
    if (getParameter("operation:machineInside") == 0) {
      R = (currentSection.spindle == SPINDLE_PRIMARY) ? 3 : 4;
    } else {
      R = (currentSection.spindle == SPINDLE_PRIMARY) ? 2 : 1;
    }
  } else {
    if ((hasParameter("operation-strategy") && getParameter("operation-strategy") == "turningFace") ||
      (hasParameter("operation-strategy") && getParameter("operation-strategy") == "turningPart")) {
      R = (currentSection.spindle == SPINDLE_PRIMARY) ? 3 : 4;
    } else {
      error(subst(localize("Failed to identify spindle orientation for operation \"%1\"."), getOperationComment()));
      return;
    }
  }
  if (leftHandTool) {
    J = (currentSection.spindle == SPINDLE_PRIMARY) ? 2 : 1;
  } else {
    J = (currentSection.spindle == SPINDLE_PRIMARY) ? 1 : 2;
  }
  writeComment("Post processor is not customized, add code for cutter orientation and cutting quadrant here if needed.");
}

var bAxisOrientationTurning = new Vector(0, 0, 0);

function onSection() {

  if (currentSection.spindle == SPINDLE_PRIMARY) {
    zFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
    zOutput = createVariable({prefix:"Z"}, zFormat);
    yFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
    yOutput = createVariable({prefix:"Y"}, yFormat);
  } else {
    zFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true, scale:-1});
    zOutput = createVariable({prefix:"Z"}, zFormat);
    yFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true, scale:-1});
    yOutput = createVariable({prefix:"Y"}, yFormat);
  }
  if (!gotYAxis) {
    yOutput.disable();
  }
  machineConfiguration = (currentSection.spindle == SPINDLE_PRIMARY) ? machineConfigurationMainSpindle : machineConfigurationSubSpindle;
  if (!gotBAxis) {
    if ((getMachiningDirection(currentSection) == MACHINING_DIRECTION_AXIAL) && !currentSection.isMultiAxis()) {
      machineConfiguration.setSpindleAxis(new Vector(0, 0, 1));
    } else {
      machineConfiguration.setSpindleAxis(new Vector(1, 0, 0));
    }
  } else {
    machineConfiguration.setSpindleAxis(new Vector(0, 0, 1)); // set the spindle axis depending on B0 orientation
  }
  setMachineConfiguration(machineConfiguration);
  currentSection.optimizeMachineAnglesByMachine(machineConfiguration, 1); // map tip mode
  
  // Define Machining modes
  tapping = hasParameter("operation:cycleType") &&
    ((getParameter("operation:cycleType") == "tapping") ||
     (getParameter("operation:cycleType") == "right-tapping") ||
     (getParameter("operation:cycleType") == "left-tapping") ||
     (getParameter("operation:cycleType") == "tapping-with-chip-breaking"));

  var forceToolAndRetract = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();

  machineState.isTurningOperation = (currentSection.getType() == TYPE_TURNING);
  if (machineState.isTurningOperation && gotBAxis) {
    bAxisOrientationTurning = getBAxisOrientationTurning(currentSection);
  }
  var insertToolCall = forceToolAndRetract || isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number) ||
    (tool.compensationOffset != getPreviousSection().getTool().compensationOffset) ||
    (tool.diameterOffset != getPreviousSection().getTool().diameterOffset) ||
    (tool.lengthOffset != getPreviousSection().getTool().lengthOffset);

  var retracted = false; // specifies that the tool has been retracted to the safe plane
  
  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (machineState.isTurningOperation &&
      abcFormat.areDifferent(bAxisOrientationTurning.x, machineState.currentBAxisOrientationTurning.x) ||
      abcFormat.areDifferent(bAxisOrientationTurning.y, machineState.currentBAxisOrientationTurning.y) ||
      abcFormat.areDifferent(bAxisOrientationTurning.z, machineState.currentBAxisOrientationTurning.z));

  partCutoff = hasParameter("operation-strategy") &&
    (getParameter("operation-strategy") == "turningPart");

  var yAxisWasEnabled = !machineState.useXZCMode && !machineState.usePolarMode && machineState.liveToolIsActive;
  updateMachiningMode(currentSection); // sets the needed machining mode to machineState (usePolarMode, useXZCMode, axialCenterDrilling)
  
  // Get the active spindle
  var newSpindle = true;
  var tempSpindle = getSpindle(false);
  var tempPartSpindle = getSpindle(true);
  if (isFirstSection()) {
    previousSpindle = tempSpindle;
    previousPartSpindle = currentSection.spindle;
  }
  newSpindle = tempSpindle != previousSpindle;
  
  // End the previous section if a new tool is selected
  if (!isFirstSection() && insertToolCall &&
      !(stockTransferIsActive && partCutoff)) {
    if (stockTransferIsActive) {
      writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_OFF", getSpindle(true))));
      /*pOutput.format(getCode("SELECT_SPINDLE", SPINDLE_MAIN))*/
    } else {
      if (previousSpindle == SPINDLE_LIVE) {
        onCommand(COMMAND_STOP_SPINDLE);
        forceUnlockMultiAxis();
        //onCommand(COMMAND_UNLOCK_MULTI_AXIS);
        writeBlock(cAxisBrakeModal.format(getCode("UNLOCK_MULTI_AXIS", previousPartSpindle)));
        if (gotSecondarySpindle && previousPartSpindle == SPINDLE_SUB) {
          writeBlock(gFormat.format(111), formatComment("Cross Axis Control cancel"));
        }
        if ((tempSpindle != SPINDLE_LIVE) && !getProperty("optimizeCaxisSelect")) {
          cAxisEngageModal.reset();
          writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", previousPartSpindle)));
        }
      }
      onCommand(COMMAND_COOLANT_OFF);
    }
    goHome();
    // mInterferModal.reset();
    // writeBlock(mInterferModal.format(getCode("INTERFERENCE_CHECK_OFF", getSpindle(true))));
    if (getProperty("optionalStop")) {
      onCommand(COMMAND_OPTIONAL_STOP);
      gMotionModal.reset();
    }
  }
  // Consider part cutoff as stockTransfer operation
  if (!(stockTransferIsActive && partCutoff)) {
    stockTransferIsActive = false;
  }

  // Output the operation description
  writeln("");
  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      if (insertToolCall && getProperty("sequenceNumberToolOnly")) {
        writeCommentSeqno(comment);
      } else {
        writeComment(comment);
      }
    }
  }

  // Position all axes at home
  if (insertToolCall && !stockTransferIsActive) {
    /*if (gotSecondarySpindle) {
      if (currentSection.spindle == SPINDLE_SECONDARY && !currentSection.spindle == SPINDLE_PRIMARY){
        writeBlock(gMotionModal.format(0), gFormat.format(53), barOutput.format(0), "(ENSURE SUB HOME BEFORE SUB OPS)" ); // retract Sub Spindle if applicable
      }
    }*/
    goHome();

    // Stop the spindle
    if (newSpindle) {
      onCommand(COMMAND_STOP_SPINDLE);
    }
  }

  // Select the active spindle
  if (insertToolCall) {
    gSelectSpindleModal.reset();
  }
  if (gotSecondarySpindle) {
    writeBlock(gSelectSpindleModal.format(getCode("ACTIVATE_SPINDLE", getSpindle(true))));

  }
  // Setup WCS code
  if (insertToolCall) { // force work offset when changing tool
    currentWorkOffset = undefined;
  }
  var workOffset = currentSection.workOffset;
  if (workOffset == 0) {
    warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
    workOffset = 1;
  }
  var wcsOut = "";
  if (workOffset > 0) {
    if (workOffset > 6) {
      error(localize("Work offset out of range."));
      return;
    } else {
      if (workOffset != currentWorkOffset) {
        forceWorkPlane();
        wcsOut = gFormat.format(53 + workOffset); // G54->G59
        currentWorkOffset = workOffset;
      }
    }
  }

  // Get active feedrate mode
  if (insertToolCall) {
    gFeedModeModal.reset();
  }
  var feedMode;
  if ((currentSection.feedMode == FEED_PER_REVOLUTION) || tapping) {
    feedMode = gFeedModeModal.format(getCode("FEED_MODE_MM_REV", getSpindle(false)));
  } else {
    feedMode = gFeedModeModal.format(getCode("FEED_MODE_MM_MIN", getSpindle(false)));
  }

  // Live Spindle is active
  if (tempSpindle == SPINDLE_LIVE) {
    writeBlock(cAxisEngageModal.format(getCode("ENABLE_C_AXIS", getSpindle(true))));
    if (insertToolCall || wcsOut || feedMode) {
      forceUnlockMultiAxis();
      //onCommand(COMMAND_UNLOCK_MULTI_AXIS);
      // var plane = getSpindleAxis() == POSZ ? getG17Code() : 18;
      var plane;
      switch (getMachiningDirection(currentSection)) {
      case MACHINING_DIRECTION_AXIAL:
        plane = getG17Code();
        break;
      case MACHINING_DIRECTION_RADIAL:
        plane = 19;
        break;
      case MACHINING_DIRECTION_INDEXING:
        plane = getG17Code();
        break;
      default:
        error(subst(localize("Unsupported machining direction for operation " + "\"" + "%1" + "\"" + "."), getOperationComment()));
        return;
      }

      gPlaneModal.reset();
      if (!getProperty("optimizeCaxisSelect")) {
        cAxisEngageModal.reset();
      }
      if (getProperty("isoModeOrMazatrol") == "ISO") {
        writeBlock(wcsOut/*, mFormat.format(getCode("SET_SPINDLE_FRAME", getSpindle(true)))*/);
      } else {
        if (currentSection.spindle == SPINDLE_SECONDARY) {
          writeBlock("G53.5 Z#150");
        } else {
          writeBlock("G53.5");
        }
      }
      writeBlock(feedMode, gPlaneModal.format(plane));
      if (currentSection.spindle == SPINDLE_SECONDARY) {
        writeBlock(gFormat.format(110), "C2", formatComment("Cross Axis Control"));
      }
      writeBlock(gMotionModal.format(0), gFormat.format(53), "H" + abcFormat.format(0)); // unwind c-axis
      if (!machineState.usePolarMode && !machineState.useXZCMode && !currentSection.isMultiAxis()) {
        //onCommand(COMMAND_LOCK_MULTI_AXIS);
      }
    } else {
      if (machineState.usePolarMode || machineState.useXZCMode || currentSection.isMultiAxis()) {
        onCommand(COMMAND_UNLOCK_MULTI_AXIS);
      }
    }

    // Turning is active
  } else {
    if ((insertToolCall || wcsOut || feedMode)) {
      gPlaneModal.reset();
      gMotionModal.reset();
      cAxisEngageModal.reset();
      writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(true))));
      if (getProperty("isoModeOrMazatrol") == "ISO") {
        writeBlock(gMotionModal.format(0), wcsOut, feedMode, gPlaneModal.format(18));
      } else {
        writeBlock(gMotionModal.format(0), feedMode, gPlaneModal.format(18));
        if (currentSection.spindle == SPINDLE_SECONDARY) {
          writeBlock("G53.5 Z#150");
        } else {
          writeBlock("G53.5");
        }
      }
      if (!getProperty("optimizeCaxisSelect")) {
        cAxisEngageModal.reset();
      }
    } else {
      writeBlock(feedMode);
    }
  }

  // Write out notes
  if (getProperty("showNotes") && hasParameter("notes")) {
    var notes = getParameter("notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }

  switch (getMachiningDirection(currentSection)) {
  case MACHINING_DIRECTION_AXIAL:
    // writeBlock(gPlaneModal.format(getG17Code()));
    break;
  case MACHINING_DIRECTION_RADIAL:
    if (gotBAxis) {
      // writeBlock(gPlaneModal.format(getG17Code()));
    } else {
      // writeBlock(gPlaneModal.format(getG17Code())); // RADIAL
    }
    break;
  case MACHINING_DIRECTION_INDEXING:
    // writeBlock(gPlaneModal.format(getG17Code())); // INDEXING
    break;
  default:
    error(subst(localize("Unsupported machining direction for operation " +  "\"" + "%1" + "\"" + "."), getOperationComment()));
    return;
  }
  
  var abc;
  if (machineConfiguration.isMultiAxisConfiguration()) {
    if (machineState.isTurningOperation) {
      if (gotBAxis) {
        cancelTransformation();
        // handle B-axis support for turning operations here
        abc = bAxisOrientationTurning;
        //setSpindleOrientationTurning();
      } else {
        abc = getWorkPlaneMachineABC(currentSection, currentSection.workPlane);
      }
    } else {
      if (currentSection.isMultiAxis()) {
        forceWorkPlane();
        cancelTransformation();
        onCommand(COMMAND_UNLOCK_MULTI_AXIS);
        abc = currentSection.getInitialToolAxisABC();
      } else {
        abc = getWorkPlaneMachineABC(currentSection, currentSection.workPlane);
      }
    }
  } else { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported by the CNC machine."));
      return;
    }
    setRotation(remaining);
  }
  
  if (insertToolCall) {
    forceWorkPlane();
    cAxisEngageModal.reset();
    retracted = true;
    onCommand(COMMAND_COOLANT_OFF);

    /** Handle multiple turrets. */
    if (gotMultiTurret) {
      var activeTurret = tool.turret;
      if (activeTurret == 0) {
        warning(localize("Turret has not been specified. Using Turret 1 as default."));
        activeTurret = 1; // upper turret as default
      }
      switch (activeTurret) {
      case 1:
        // add specific handling for turret 1
        break;
      case 2:
        // add specific handling for turret 2, normally X-axis is reversed for the lower turret
        //xFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true, scale:-1}); // inverted diameter mode
        //xOutput = createVariable({prefix:"X"}, xFormat);
        break;
      default:
        error(localize("Turret is not supported."));
        return;
      }
    }

    var compensationOffset = tool.isTurningTool() ? tool.compensationOffset : tool.lengthOffset;
    if (compensationOffset > 99) {
      error(localize("Compensation offset is out of range."));
      return;
    }

    if (tool.number > getProperty("maxTool")) {
      warning(localize("Tool number exceeds maximum value."));
    }
    
    if (tool.number == 0) {
      error(localize("Tool number cannot be 0"));
      return;
    }

    gMotionModal.reset();
    writeBlock("T" + toolFormat.format(tool.number * 100 + compensationOffset)
    + conditional(tool.productId, "." + tool.productId));
    if (tool.comment) {
      writeComment(tool.comment);
    }

    // Write out maximum spindle speed
    if (insertToolCall) {
      if ((tool.maximumSpindleSpeed > 0) && (currentSection.getTool().getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED)) {
        var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, getProperty("maximumSpindleSpeed")) : getProperty("maximumSpindleSpeed");
        writeBlock(gFormat.format(50),
          sOutput.format(maximumSpindleSpeed),
          rcssOutput.format(getCode("SELECT_SPINDLE", getSpindle(true)))
        );
        sOutput.reset();
      }
    }

    // Engage tailstock
    if (getProperty("useTailStock")) {
      if (machineState.axialCenterDrilling || (currentSection.spindle == SPINDLE_SECONDARY) ||
       (machineState.liveToolIsActive && (getMachiningDirection(currentSection) == MACHINING_DIRECTION_AXIAL))) {
        if (currentSection.tailstock) {
          warning(localize("Tail stock is not supported for secondary spindle or Z-axis milling."));
        }
        if (machineState.tailstockIsActive) {
          writeBlock(getCode("TAILSTOCK_OFF"));
          writeBlock(mFormat.format(32), formatComment("RETURN TAILSTOCK TO HOME POSITION"));
        }
      } else {
        writeBlock(currentSection.tailstock ? getCode("TAILSTOCK_ON") : getCode("TAILSTOCK_OFF"));
        if (!machineState.tailstockIsActive) {
          writeBlock(mFormat.format(32), formatComment("RETURN TAILSTOCK TO HOME POSITION"));
        }
      }
    }
  }

  // Activate part catcher for part cutoff section
  if (getProperty("gotPartCatcher") && partCutoff && currentSection.partCatcher) {
    engagePartCatcher(true);
  }

  // command stop for manual tool change, useful for quick change live tools
  if (insertToolCall && tool.manualToolChange) {
    onCommand(COMMAND_STOP);
    writeBlock("(" + "MANUAL TOOL CHANGE TO T" + toolFormat.format(tool.number * 100 + compensationOffset) + ")");
  }

  // Output spindle codes
  if (newSpindle) {
    // select spindle if required
  }

  if ((insertToolCall ||
      newSpindle ||
      isFirstSection() ||
      isSpindleSpeedDifferent())) {
    if (machineState.isTurningOperation) {
      if (spindleSpeed > getProperty("maximumSpindleSpeed")) {
        warning(subst(localize("Spindle speed exceeds maximum value for operation \"%1\"."), getOperationComment()));
      }
    } else {
      if (spindleSpeed > maximumSpindleSpeedLive) {
        warning(subst(localize("Spindle speed exceeds maximum value for operation \"%1\"."), getOperationComment()));
      }
    }
    // Turn spindle on
    startSpindle(false, true, getFramePosition(currentSection.getInitialPosition()));
  }

  // Turn off interference checking with secondary spindle
  // if (getSpindle(true) == SPINDLE_SUB) {
  // writeBlock(mInterferModal.format(getCode("INTERFERENCE_CHECK_OFF", getSpindle(true))));
  // }

  forceAny();
  gMotionModal.reset();

  if (currentSection.isMultiAxis()) {
    writeBlock(gMotionModal.format(0), aOutput.format(abc.x), bOutput.format(abc.y), cOutput.format(abc.z));
    previousABC = abc;
    forceWorkPlane();
    cancelTransformation();
  } else {
    if (machineState.isTurningOperation || machineState.axialCenterDrilling) {
      if (gotBAxis) {
        bOutput.reset();
        writeBlock(gMotionModal.format(0), bOutput.format(getB(abc, currentSection)));
        machineState.currentBAxisOrientationTurning = abc;
      }
    } else if (!machineState.useXZCMode && !machineState.usePolarMode) {
      setWorkPlane(abc);
    }
  }
  forceAny();
  if (abc !== undefined) {
    cOutput.format(abc.z); // make C current - we do not want to output here
  }
  gMotionModal.reset();
  var initialPosition = getFramePosition(currentSection.getInitialPosition());

  if (insertToolCall || retracted || (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED)) {
    // gPlaneModal.reset();
    gMotionModal.reset();
    if (machineState.useXZCMode || machineState.usePolarMode) {
      // writeBlock(gPlaneModal.format(getG17Code()));
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
      writeBlock(
        gMotionModal.format(0),
        xOutput.format(getModulus(initialPosition.x, initialPosition.y)),
        conditional(gotYAxis, yOutput.format(0)),
        conditional(machineState.useXZCMode, cOutput.format(getC(initialPosition.x, initialPosition.y)))
      );
      setCoolant(tool.coolant);
    } else {
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
      writeBlock(gMotionModal.format(0), xOutput.format(initialPosition.x),
        conditional(gotYAxis, yOutput.format(initialPosition.y)));
      setCoolant(tool.coolant);
    }
  } else if ((machineState.useXZCMode || machineState.usePolarMode) && yAxisWasEnabled) {
    if (gotYAxis && yOutput.isEnabled()) {
      writeBlock(gMotionModal.format(0), yOutput.format(0));
    }
  }

  // enable SFM spindle speed
  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    startSpindle(false, false);
  }

  if (machineState.usePolarMode) {
    setPolarMode(true); // enable polar interpolation mode
  }

  if (getProperty("useParametricFeed") &&
      hasParameter("operation-strategy") &&
      (getParameter("operation-strategy") != "drill") && // legacy
      !(currentSection.hasAnyCycle && currentSection.hasAnyCycle())) {
    if (!insertToolCall &&
        activeMovements &&
        (getCurrentSectionId() > 0) &&
        ((getPreviousSection().getPatternId() == currentSection.getPatternId()) && (currentSection.getPatternId() != 0))) {
      // use the current feeds
    } else {
      initializeActiveFeeds();
    }
  } else {
    activeMovements = undefined;
  }
  
  previousSpindle = tempSpindle;
  previousPartSpindle = tempPartSpindle;
  activeSpindle = tempSpindle;

  if (false) { // DEBUG
    for (var key in machineState) {
      writeComment(key + " : " + machineState[key]);
    }
    writeComment("Machining direction = " + getMachiningDirection(currentSection));
    writeComment("Tapping = " + tapping);
    // writeln("(" + (getMachineConfigurationAsText(machineConfiguration)) + ")");
  }
}

/** Returns true if the toolpath fits within the machine XY limits for the given C orientation. */
function doesToolpathFitInXYRange(abc) {
  var xMin = xAxisMinimum * Math.abs(xFormat.getScale());
  var yMin = yAxisMinimum * Math.abs(yFormat.getScale());
  var yMax = yAxisMaximum * Math.abs(yFormat.getScale());
  var c = 0;
  if (abc) {
    c = abc.z;
  }
  if (Vector.dot(machineConfiguration.getAxisU().getAxis(), new Vector(0, 0, 1)) != 0) {
    c *= (machineConfiguration.getAxisU().getAxis().getCoordinate(2) >= 0) ? 1 : -1; // C-axis is the U-axis
  } else {
    c *= (machineConfiguration.getAxisV().getAxis().getCoordinate(2) >= 0) ? 1 : -1; // C-axis is the V-axis
  }

  var dx = new Vector(Math.cos(c), Math.sin(c), 0);
  var dy = new Vector(Math.cos(c + Math.PI / 2), Math.sin(c + Math.PI / 2), 0);

  if (currentSection.getGlobalRange) {
    var xRange = currentSection.getGlobalRange(dx);
    var yRange = currentSection.getGlobalRange(dy);

    if (false) { // DEBUG
      writeComment(
        "toolpath X minimum= " + xFormat.format(xRange[0]) + ", " + "Limit= " + xMin + ", " +
        "within range= " + (xFormat.getResultingValue(xRange[0]) >= xMin)
      );
      writeComment(
        "toolpath Y minimum= " + yFormat.getResultingValue(yRange[0]) + ", " + "Limit= " + yMin + ", " +
        "within range= " + (yFormat.getResultingValue(yRange[0]) >= yMin)
      );
      writeComment(
        "toolpath Y maximum= " + (yFormat.getResultingValue(yRange[1]) + ", " + "Limit= " + yMax) + ", " +
        "within range= " + (yFormat.getResultingValue(yRange[1]) <= yMax)
      );
      writeln("");
    }

    if (getMachiningDirection(currentSection) == MACHINING_DIRECTION_RADIAL) { // G19 plane
      if ((yFormat.getResultingValue(yRange[0]) >= yMin) &&
          (yFormat.getResultingValue(yRange[1]) <= yMax)) {
        return true; // toolpath does fit in XY range
      } else {
        return false; // toolpath does not fit in XY range
      }
    } else { // G17 plane
      if ((xFormat.getResultingValue(xRange[0]) >= xMin) &&
          (yFormat.getResultingValue(yRange[0]) >= yMin) &&
          (yFormat.getResultingValue(yRange[1]) <= yMax)) {
        return true; // toolpath does fit in XY range
      } else {
        return false; // toolpath does not fit in XY range
      }
    }
  } else {
    if (revision < 40000) {
      warning(localize("Please update to the latest release to allow XY linear interpolation instead of polar interpolation."));
    }
    return false; // for older versions without the getGlobalRange() function
  }
}

var MACHINING_DIRECTION_AXIAL = 0;
var MACHINING_DIRECTION_RADIAL = 1;
var MACHINING_DIRECTION_INDEXING = 2;

function getMachiningDirection(section) {
  var forward = section.isMultiAxis() ? section.getGlobalInitialToolAxis() : section.workPlane.forward;
  if (isSameDirection(forward, new Vector(0, 0, 1))) {
    return MACHINING_DIRECTION_AXIAL;
  } else if (Vector.dot(forward, new Vector(0, 0, 1)) < 1e-7) {
    return MACHINING_DIRECTION_RADIAL;
  } else {
    return MACHINING_DIRECTION_INDEXING;
  }
}

function updateMachiningMode(section) {
  machineState.axialCenterDrilling = false; // reset
  machineState.usePolarMode = false; // reset
  machineState.useXZCMode = false; // reset

  if ((section.getType() == TYPE_MILLING) && !section.isMultiAxis()) {
    if (getMachiningDirection(section) == MACHINING_DIRECTION_AXIAL) {
      if (section.hasParameter("operation-strategy") && (section.getParameter("operation-strategy") == "drill")) {
        // drilling axial
        if ((section.getNumberOfCyclePoints() == 1) &&
            !xFormat.isSignificant(getGlobalPosition(section.getInitialPosition()).x) &&
            !yFormat.isSignificant(getGlobalPosition(section.getInitialPosition()).y) &&
            (spatialFormat.format(section.getFinalPosition().x) == 0) &&
            !doesCannedCycleIncludeYAxisMotion(section)) { // catch drill issue for old versions
          // single hole on XY center
          if (section.getTool().isLiveTool && section.getTool().isLiveTool()) {
            // use live tool
          } else {
            // use main spindle for axialCenterDrilling
            machineState.axialCenterDrilling = true;
          }
        } else {
          // several holes not on XY center
          bestABCIndex = getBestABCIndex(section);
          if (getProperty("useYAxisForDrilling") && (bestABCIndex != undefined) && !doesCannedCycleIncludeYAxisMotion(section)) {
            // use XYZ-mode
          } else { // use XZC mode
            machineState.useXZCMode = true;
            bestABCIndex = undefined;
          }
        }
      } else { // milling
        if (gotPolarInterpolation && forcePolarMode) { // polar mode is requested by user
          machineState.usePolarMode = true;
        } else if (forceXZCMode) { // XZC mode is requested by user
          machineState.useXZCMode = true;
        } else { // see if toolpath fits in XY-range
          fitFlag = false;
          bestABCIndex = undefined;
          for (var i = 0; i < 6; ++i) {
            fitFlag = doesToolpathFitInXYRange(getBestABC(section, section.workPlane, i));
            if (fitFlag) {
              bestABCIndex = i;
              break;
            }
          }
          if (!fitFlag) { // does not fit, set polar/XZC mode
            if (gotPolarInterpolation) {
              machineState.usePolarMode = true;
            } else {
              machineState.useXZCMode = true;
            }
          }
        }
      }
    } else if (getMachiningDirection(section) == MACHINING_DIRECTION_RADIAL) { // G19 plane
      if (!gotYAxis) {
        if (!section.isMultiAxis() && (!doesToolpathFitInXYRange(machineConfiguration.getABC(section.workPlane)) || doesCannedCycleIncludeYAxisMotion(section))) {
          error(subst(localize("Y-axis motion is not possible without a Y-axis for operation \"%1\"."), getOperationComment()));
          return;
        }
      } else {
        if ((!section.isMultiAxis() && !doesToolpathFitInXYRange(machineConfiguration.getABC(section.workPlane)) &&
            doesCannedCycleIncludeYAxisMotion(section)) || forceXZCMode) {
          error(subst(localize("Toolpath exceeds the maximum ranges for operation \"%1\"."), getOperationComment()));
          return;
        }
      }
      // C-coordinates come from setWorkPlane or is within a multi axis operation, we cannot use the C-axis for non wrapped toolpathes (only multiaxis works, all others have to be into XY range)
    } else {
      // useXZCMode & usePolarMode is only supported for axial machining, keep false
    }
  } else {
    // turning or multi axis, keep false
  }

  if (machineState.axialCenterDrilling) {
    cOutput.disable();
  } else {
    cOutput.enable();
  }

  var checksum = 0;
  checksum += machineState.usePolarMode ? 1 : 0;
  checksum += machineState.useXZCMode ? 1 : 0;
  checksum += machineState.axialCenterDrilling ? 1 : 0;
  validate(checksum <= 1, localize("Internal post processor error."));
}

function doesCannedCycleIncludeYAxisMotion(section) {
  // these cycles have Y axis motions which are not detected by getGlobalRange()
  var hasYMotion = false;
  if (section.hasParameter("operation:strategy") && (section.getParameter("operation:strategy") == "drill")) {
    switch (section.getParameter("operation:cycleType")) {
    case "thread-milling":
    case "bore-milling":
    case "circular-pocket-milling":
      hasYMotion = true; // toolpath includes Y-axis motion
      break;
    case "back-boring":
    case "fine-boring":
      var shift = getParameter("operation:boringShift");
      if (shift != spatialFormat.format(0)) {
        hasYMotion = true; // toolpath includes Y-axis motion
      }
      break;
    default:
      hasYMotion = false; // all other cycles don´t have Y-axis motion
    }
  }
  return hasYMotion;
}

function getOperationComment() {
  var operationComment = hasParameter("operation-comment") && getParameter("operation-comment");
  return operationComment;
}

function setPolarMode(activate) {
  if (activate) {
    cOutput.enable();
    cOutput.reset();
    writeBlock(gMotionModal.format(0), cOutput.format(0)); // set C-axis to 0 to avoid G112 issues
    writeBlock(gFormat.format(17), "XC");
    writeBlock(gPolarModal.format(getCode("POLAR_INTERPOLATION_ON", getSpindle(true)))); // command for polar interpolation
    writeBlock(gPlaneModal.format(getG17Code()));
    yOutput = createVariable({prefix:"C"}, yFormat);
    yOutput.enable(); // required for G12.1
    cOutput.disable();
  } else {
    writeBlock(gPolarModal.format(getCode("POLAR_INTERPOLATION_OFF", getSpindle(true))));
    yOutput = createVariable({prefix:"Y"}, yFormat);
    if (!gotYAxis) {
      yOutput.disable();
    }
    cOutput.enable();
  }
}

function goHome() {
  var yAxis = "";
  if (gotYAxis) {
    yAxis = "Y" + yFormat.format(0);
  }
  writeBlock(gMotionModal.format(0), gFormat.format(53), "X" + xFormat.format(0), yAxis);
  if (getProperty("useG53Zhome")) {
    writeBlock(gMotionModal.format(0), gFormat.format(53), "Z" + zFormat.format(0));
  } else {
    gMotionModal.reset();
    zOutput.reset();
    writeBlock(gMotionModal.format(0), zOutput.format(getProperty("zHomePosition")));
  }
}

function onDwell(seconds) {
  if (seconds > 99999.999) {
    warning(localize("Dwelling time is out of range."));
  }
  writeBlock(gFormat.format(4), dwellFormat.format(seconds));
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

var resetFeed = false;

function getHighfeedrate(radius) {
  if (currentSection.feedMode == FEED_PER_REVOLUTION) {
    if (toDeg(radius) <= 0) {
      radius = toPreciseUnit(0.1, MM);
    }
    var rpm = spindleSpeed; // rev/min
    if (currentSection.getTool().getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
      var O = 2 * Math.PI * radius; // in/rev
      rpm = tool.surfaceSpeed / O; // in/min div in/rev => rev/min
    }
    return highFeedrate / rpm; // in/min div rev/min => in/rev
  }
  return highFeedrate;
}

function onRapid(_x, _y, _z) {
  if (machineState.useXZCMode) {
    var start = getCurrentPosition();
    var dxy = getModulus(_x - start.x, _y - start.y);
    if (true || (dxy < getTolerance())) {
      var x = xOutput.format(getModulus(_x, _y));
      var currentC = getCClosest(_x, _y, cOutput.getCurrent());
      var c = cOutput.format(currentC);
      var z = zOutput.format(_z);
      if (pendingRadiusCompensation >= 0) {
        error(localize("Radius compensation mode cannot be changed at rapid traversal."));
        return;
      }
      writeBlock(gMotionModal.format(0), x, c, z);
      previousABC.setZ(currentC);
      forceFeed();
      return;
    }

    onExpandedLinear(_x, _y, _z, highFeedrate);
    return;
  }

  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    var useG1 = ((((x ? 1 : 0) + (y ? 1 : 0) + (z ? 1 : 0)) > 1) || machineState.usePolarMode) && !isCannedCycle;
    var highFeed = machineState.usePolarMode ? toPreciseUnit(1500, MM) : getHighfeedrate(_x);
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      if (useG1) {
        switch (radiusCompensation) {
        case RADIUS_COMPENSATION_LEFT:
          writeBlock(gMotionModal.format(1), gFormat.format(41), x, y, z, getFeed(highFeed));
          break;
        case RADIUS_COMPENSATION_RIGHT:
          writeBlock(gMotionModal.format(1), gFormat.format(42), x, y, z, getFeed(highFeed));
          break;
        default:
          writeBlock(gMotionModal.format(1), gFormat.format(40), x, y, z, getFeed(highFeed));
        }
      } else {
        switch (radiusCompensation) {
        case RADIUS_COMPENSATION_LEFT:
          writeBlock(gMotionModal.format(0), gFormat.format(41), x, y, z);
          break;
        case RADIUS_COMPENSATION_RIGHT:
          writeBlock(gMotionModal.format(0), gFormat.format(42), x, y, z);
          break;
        default:
          writeBlock(gMotionModal.format(0), gFormat.format(40), x, y, z);
        }
      }
    } else {
      if (useG1) {
        // axes are not synchronized
        writeBlock(gMotionModal.format(1), x, y, z, getFeed(highFeed));
        resetFeed = false;
      } else {
        writeBlock(gMotionModal.format(0), x, y, z);
        // forceFeed();
      }
    }
  }
}

/** Calculate the distance of a point to a line segment. */
function pointLineDistance(startPt, endPt, testPt) {
  var delta = Vector.diff(endPt, startPt);
  distance = Math.abs(delta.y * testPt.x - delta.x * testPt.y + endPt.x * startPt.y - endPt.y * startPt.x) /
    Math.sqrt(delta.y * delta.y + delta.x * delta.x); // distance from line to point
  if (distance < 1e-4) { // make sure point is in line segment
    var moveLength = Vector.diff(endPt, startPt).length;
    var startLength = Vector.diff(startPt, testPt).length;
    var endLength = Vector.diff(endPt, testPt).length;
    if ((startLength > moveLength) || (endLength > moveLength)) {
      distance = Math.min(startLength, endLength);
    }
  }
  return distance;
}

/** Refine segment for XC mapping. */
function refineSegmentXC(startX, startC, endX, endC, maximumDistance) {
  var rotary = machineConfiguration.getAxisU(); // C-axis
  var startPt = rotary.getAxisRotation(startC).multiply(new Vector(startX, 0, 0));
  var endPt = rotary.getAxisRotation(endC).multiply(new Vector(endX, 0, 0));

  var testX = startX + (endX - startX) / 2; // interpolate as the machine
  var testC = startC + (endC - startC) / 2;
  var testPt = rotary.getAxisRotation(testC).multiply(new Vector(testX, 0, 0));

  var delta = Vector.diff(endPt, startPt);
  var distf = pointLineDistance(startPt, endPt, testPt);

  if (distf > maximumDistance) {
    return false; // out of tolerance
  } else {
    return true;
  }
}

function onLinear(_x, _y, _z, feed) {
  if (machineState.useXZCMode) {
    if (pendingRadiusCompensation >= 0) {
      error(subst(localize("Radius compensation is not supported for operation \"%1\"."), getOperationComment()));
      return;
    }
    if (maximumCircularSweep > toRad(179)) {
      error(localize("Maximum circular sweep must be below 179 degrees."));
      return;
    }

    var localTolerance = getTolerance() / 2;
    var startXYZ = getCurrentPosition();
    var startX = getModulus(startXYZ.x, startXYZ.y);
    var startZ = startXYZ.z;
    var startC = cOutput.getCurrent();

    var endXYZ = new Vector(_x, _y, _z);
    var endX = getModulus(endXYZ.x, endXYZ.y);
    var endZ = endXYZ.z;
    // var endC = getCWithinRange(endXYZ.x, endXYZ.y, startC);
    var endC = getCClosest(endXYZ.x, endXYZ.y, startC);

    var currentXYZ = endXYZ; var currentX = endX; var currentZ = endZ; var currentC = endC;
    var centerXYZ = machineConfiguration.getAxisU().getOffset();

    var refined = true;
    var crossingRotary = false;
    forceOptimized = false; // tool tip is provided to DPM calculations
    while (refined) { // stop if we dont refine
      // check if we cross center of rotary axis
      var _start = new Vector(startXYZ.x, startXYZ.y, 0);
      var _current = new Vector(currentXYZ.x, currentXYZ.y, 0);
      var _center = new Vector(centerXYZ.x, centerXYZ.y, 0);
      if ((xFormat.getResultingValue(pointLineDistance(_start, _current, _center)) == 0) &&
        (xFormat.getResultingValue(Vector.diff(_start, _center).length) != 0) &&
        (xFormat.getResultingValue(Vector.diff(_current, _center).length) != 0)) {
        var ratio = Vector.diff(_center, _start).length / Vector.diff(_current, _start).length;
        currentXYZ = centerXYZ;
        currentXYZ.z = startZ + (endZ - startZ) * ratio;
        currentX = getModulus(currentXYZ.x, currentXYZ.y);
        currentZ = currentXYZ.z;
        currentC = startC;
        crossingRotary = true;
      } else { // check if move is out of tolerance
        refined = false;
        while (!refineSegmentXC(startX, startC, currentX, currentC, localTolerance)) { // move is out of tolerance
          refined = true;
          currentXYZ = Vector.lerp(startXYZ, currentXYZ, 0.75);
          currentX = getModulus(currentXYZ.x, currentXYZ.y);
          currentZ = currentXYZ.z;
          // currentC = getCWithinRange(currentXYZ.x, currentXYZ.y, startC);
          currentC = getCClosest(currentXYZ.x, currentXYZ.y, startC);
          if (Vector.diff(startXYZ, currentXYZ).length < 1e-5) { // back to start point, output error
            /*if (forceRewind) {
              break;
            } else*/ {
              warning(localize("Linear move cannot be mapped to rotary XZC motion."));
              break;
            }
          }
        }
      }

      // currentC = getCWithinRange(currentXYZ.x, currentXYZ.y, startC);
      currentC = getCClosest(currentXYZ.x, currentXYZ.y, startC);
      /*if (forceRewind) {
        var rewindC = getCClosest(startXYZ.x, startXYZ.y, currentC);
        xOutput.reset(); // force X for repositioning
        rewindTable(startXYZ, currentZ, rewindC, feed, true);
        previousABC.setZ(rewindC);
      }*/
      var x = xOutput.format(currentX);
      var c = cOutput.format(currentC);
      var z = zOutput.format(currentZ);
      var actualFeed = getMultiaxisFeed(currentXYZ.x, currentXYZ.y, currentXYZ.z, 0, 0, currentC, feed);
      if (x || c || z) {
        writeBlock(gMotionModal.format(1), x, c, z, getFeed(actualFeed.frn));
      }
      setCurrentPosition(currentXYZ);
      previousABC.setZ(currentC);
      if (crossingRotary) {
        writeBlock(gMotionModal.format(1), cOutput.format(endC), getFeed(feed)); // rotate at X0 with endC
        previousABC.setZ(endC);
        forceFeed();
      }
      startX = currentX; startZ = currentZ; startC = crossingRotary ? endC : currentC; startXYZ = currentXYZ; // loop start point
      currentX = endX; currentZ = endZ; currentC = endC; currentXYZ = endXYZ; // loop end point
      crossingRotary = false;
    }
    forceOptimized = undefined;
    return;
  }

  if (isSpeedFeedSynchronizationActive()) {
    resetFeed = true;
    var threadPitch = getParameter("operation:threadPitch");
    var threadsPerInch = 1.0 / threadPitch; // per mm for metric
    writeBlock(gMotionModal.format(32), xOutput.format(_x), yOutput.format(_y), zOutput.format(_z), pitchOutput.format(1 / threadsPerInch));
    return;
  }
  if (resetFeed) {
    resetFeed = false;
    forceFeed();
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      if (machineState.isTurningOperation) {
        writeBlock(gPlaneModal.format(18));
      } else if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
        writeBlock(gPlaneModal.format(getG17Code()));
      } else if (Vector.dot(currentSection.workPlane.forward, new Vector(0, 0, 1)) < 1e-7) {
        writeBlock(gPlaneModal.format(19));
      } else {
        error(localize("Tool orientation is not supported for radius compensation."));
        return;
      }
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(
          gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1),
          gFormat.format((getSpindle(true) == SPINDLE_MAIN) ? 41 : 42),
          x, y, z, f
        );
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(
          gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1),
          gFormat.format((getSpindle(true) == SPINDLE_MAIN) ? 42 : 41),
          x, y, z, f
        );
        break;
      default:
        writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("Multi-axis motion is not supported for XZC mode."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);
  if (true) {
    // axes are not synchronized
    var actualFeed = getMultiaxisFeed(_x, _y, _z, _a, _b, _c, highFeedrate);
    writeBlock(gMotionModal.format(1), x, y, z, a, b, c, getFeed(actualFeed.frn));
  } else {
    writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
    forceFeed();
  }
  previousABC = new Vector(_a, _b, _c);
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("Multi-axis motion is not supported for XZC mode."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);

  var actualFeed = getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed);
  var f = getFeed(actualFeed.frn);

  if (x || y || z || a || b || c) {
    writeBlock(gMotionModal.format(1), x, y, z, a, b, c, f);
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
  previousABC = new Vector(_a, _b, _c);
}

// Start of multi-axis feedrate logic
/***** Be sure to add 'useInverseTime' to post properties if necessary. *****/
/***** 'inverseTimeOutput' should be defined if Inverse Time feedrates are supported. *****/
/***** 'previousABC' can be added throughout to maintain previous rotary positions. Required for Mill/Turn machines. *****/
/***** 'headOffset' should be defined when a head rotary axis is defined. *****/
/***** The feedrate mode must be included in motion block output (linear, circular, etc.) for Inverse Time feedrate support. *****/
var dpmBPW = 0.1; // ratio of rotary accuracy to linear accuracy for DPM calculations
var inverseTimeUnits = 1.0; // 1.0 = minutes, 60.0 = seconds
var maxInverseTime = 45000; // maximum value to output for Inverse Time feeds
var maxDPM = 4800; // maximum value to output for DPM feeds
var useInverseTimeFeed = false; // use DPM feeds
var previousDPMFeed = 0; // previously output DPM feed
var dpmFeedToler = 0.5; // tolerance to determine when the DPM feed has changed
var previousABC = new Vector(0, 0, 0); // previous ABC position if maintained in post, don't define if not used
var forceOptimized = undefined; // used to override optimized-for-angles points (XZC-mode)

/** Calculate the multi-axis feedrate number. */
function getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed) {
  var f = {frn:0, fmode:0};
  if (feed <= 0) {
    error(localize("Feedrate is less than or equal to 0."));
    return f;
  }
  
  var length = getMoveLength(_x, _y, _z, _a, _b, _c);
  
  if (useInverseTimeFeed) { // inverse time
    f.frn = getInverseTime(length.tool, feed);
    f.fmode = 93;
    feedOutput.reset();
  } else { // degrees per minute
    f.frn = getFeedDPM(length, feed);
    f.fmode = 94;
  }
  return f;
}

/** Returns point optimization mode. */
function getOptimizedMode() {
  if (forceOptimized != undefined) {
    return forceOptimized;
  }
  // return (currentSection.getOptimizedTCPMode() != 0); // TAG:doesn't return correct value
  return true; // always return false for non-TCP based heads
}
  
/** Calculate the DPM feedrate number. */
function getFeedDPM(_moveLength, _feed) {
  if ((_feed == 0) || (_moveLength.tool < 0.0001) || (toDeg(_moveLength.abcLength) < 0.0005)) {
    previousDPMFeed = 0;
    return _feed;
  }
  var moveTime = _moveLength.tool / _feed;
  if (moveTime == 0) {
    previousDPMFeed = 0;
    return _feed;
  }

  var dpmFeed;
  var tcp = !getOptimizedMode() && (forceOptimized == undefined);   // set to false for rotary heads
  if (tcp) { // TCP mode is supported, output feed as FPM
    dpmFeed = _feed;
  } else if (true) { // standard DPM
    dpmFeed = Math.min(toDeg(_moveLength.abcLength) / moveTime, maxDPM);
    if (Math.abs(dpmFeed - previousDPMFeed) < dpmFeedToler) {
      dpmFeed = previousDPMFeed;
    }
  } else if (false) { // combination FPM/DPM
    var length = Math.sqrt(Math.pow(_moveLength.xyzLength, 2.0) + Math.pow((toDeg(_moveLength.abcLength) * dpmBPW), 2.0));
    dpmFeed = Math.min((length / moveTime), maxDPM);
    if (Math.abs(dpmFeed - previousDPMFeed) < dpmFeedToler) {
      dpmFeed = previousDPMFeed;
    }
  } else { // machine specific calculation
    dpmFeed = _feed;
  }
  previousDPMFeed = dpmFeed;
  return dpmFeed;
}

/** Calculate the Inverse time feedrate number. */
function getInverseTime(_length, _feed) {
  var inverseTime;
  if (_length < 1.e-6) { // tool doesn't move
    if (typeof maxInverseTime === "number") {
      inverseTime = maxInverseTime;
    } else {
      inverseTime = 999999;
    }
  } else {
    inverseTime = _feed / _length / inverseTimeUnits;
    if (typeof maxInverseTime === "number") {
      if (inverseTime > maxInverseTime) {
        inverseTime = maxInverseTime;
      }
    }
  }
  return inverseTime;
}

/** Calculate radius for each rotary axis. */
function getRotaryRadii(startTool, endTool, startABC, endABC) {
  var radii = new Vector(0, 0, 0);
  var startRadius;
  var endRadius;
  var axis = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
  for (var i = 0; i < 3; ++i) {
    if (axis[i].isEnabled()) {
      var startRadius = getRotaryRadius(axis[i], startTool, startABC);
      var endRadius = getRotaryRadius(axis[i], endTool, endABC);
      radii.setCoordinate(axis[i].getCoordinate(), Math.max(startRadius, endRadius));
    }
  }
  return radii;
}

/** Calculate the distance of the tool position to the center of a rotary axis. */
function getRotaryRadius(axis, toolPosition, abc) {
  if (!axis.isEnabled()) {
    return 0;
  }

  var direction = axis.getEffectiveAxis();
  var normal = direction.getNormalized();
  // calculate the rotary center based on head/table
  var center;
  var radius;
  if (axis.isHead()) {
    var pivot;
    if (typeof headOffset === "number") {
      pivot = headOffset;
    } else {
      pivot = tool.getBodyLength();
    }
    if (axis.getCoordinate() == machineConfiguration.getAxisU().getCoordinate()) { // rider
      center = Vector.sum(toolPosition, Vector.product(machineConfiguration.getDirection(abc), pivot));
      center = Vector.sum(center, axis.getOffset());
      radius = Vector.diff(toolPosition, center).length;
    } else { // carrier
      var angle = abc.getCoordinate(machineConfiguration.getAxisU().getCoordinate());
      radius = Math.abs(pivot * Math.sin(angle));
      radius += axis.getOffset().length;
    }
  } else {
    center = axis.getOffset();
    var d1 = toolPosition.x - center.x;
    var d2 = toolPosition.y - center.y;
    var d3 = toolPosition.z - center.z;
    var radius = Math.sqrt(
      Math.pow((d1 * normal.y) - (d2 * normal.x), 2.0) +
      Math.pow((d2 * normal.z) - (d3 * normal.y), 2.0) +
      Math.pow((d3 * normal.x) - (d1 * normal.z), 2.0)
    );
  }
  return radius;
}
  
/** Calculate the linear distance based on the rotation of a rotary axis. */
function getRadialDistance(radius, startABC, endABC) {
  // calculate length of radial move
  var delta = Math.abs(endABC - startABC);
  if (delta > Math.PI) {
    delta = 2 * Math.PI - delta;
  }
  var radialLength = (2 * Math.PI * radius) * (delta / (2 * Math.PI));
  return radialLength;
}
  
/** Calculate tooltip, XYZ, and rotary move lengths. */
function getMoveLength(_x, _y, _z, _a, _b, _c) {
  // get starting and ending positions
  var moveLength = {};
  var startTool;
  var endTool;
  var startXYZ;
  var endXYZ;
  var startABC;
  if (typeof previousABC !== "undefined") {
    startABC = new Vector(previousABC.x, previousABC.y, previousABC.z);
  } else {
    startABC = getCurrentDirection();
  }
  var endABC = new Vector(_a, _b, _c);
    
  if (!getOptimizedMode()) { // calculate XYZ from tool tip
    startTool = getCurrentPosition();
    endTool = new Vector(_x, _y, _z);
    startXYZ = startTool;
    endXYZ = endTool;

    // adjust points for tables
    if (!machineConfiguration.getTableABC(startABC).isZero() || !machineConfiguration.getTableABC(endABC).isZero()) {
      startXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).getTransposed().multiply(startXYZ);
      endXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).getTransposed().multiply(endXYZ);
    }

    // adjust points for heads
    if (machineConfiguration.getAxisU().isEnabled() && machineConfiguration.getAxisU().isHead()) {
      if (typeof getOptimizedHeads === "function") { // use post processor function to adjust heads
        startXYZ = getOptimizedHeads(startXYZ.x, startXYZ.y, startXYZ.z, startABC.x, startABC.y, startABC.z);
        endXYZ = getOptimizedHeads(endXYZ.x, endXYZ.y, endXYZ.z, endABC.x, endABC.y, endABC.z);
      } else { // guess at head adjustments
        var startDisplacement = machineConfiguration.getDirection(startABC);
        startDisplacement.multiply(headOffset);
        var endDisplacement = machineConfiguration.getDirection(endABC);
        endDisplacement.multiply(headOffset);
        startXYZ = Vector.sum(startTool, startDisplacement);
        endXYZ = Vector.sum(endTool, endDisplacement);
      }
    }
  } else { // calculate tool tip from XYZ, heads are always programmed in TCP mode, so not handled here
    startXYZ = getCurrentPosition();
    endXYZ = new Vector(_x, _y, _z);
    startTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).multiply(startXYZ);
    endTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).multiply(endXYZ);
  }

  // calculate axes movements
  moveLength.xyz = Vector.diff(endXYZ, startXYZ).abs;
  moveLength.xyzLength = moveLength.xyz.length;
  moveLength.abc = Vector.diff(endABC, startABC).abs;
  for (var i = 0; i < 3; ++i) {
    if (moveLength.abc.getCoordinate(i) > Math.PI) {
      moveLength.abc.setCoordinate(i, 2 * Math.PI - moveLength.abc.getCoordinate(i));
    }
  }
  moveLength.abcLength = moveLength.abc.length;

  // calculate radii
  moveLength.radius = getRotaryRadii(startTool, endTool, startABC, endABC);
  
  // calculate the radial portion of the tool tip movement
  var radialLength = Math.sqrt(
    Math.pow(getRadialDistance(moveLength.radius.x, startABC.x, endABC.x), 2.0) +
    Math.pow(getRadialDistance(moveLength.radius.y, startABC.y, endABC.y), 2.0) +
    Math.pow(getRadialDistance(moveLength.radius.z, startABC.z, endABC.z), 2.0)
  );
  
  // calculate the tool tip move length
  // tool tip distance is the move distance based on a combination of linear and rotary axes movement
  moveLength.tool = moveLength.xyzLength + radialLength;

  // debug
  if (false) {
    writeComment("DEBUG - tool   = " + moveLength.tool);
    writeComment("DEBUG - xyz    = " + moveLength.xyz);
    var temp = Vector.product(moveLength.abc, 180 / Math.PI);
    writeComment("DEBUG - abc    = " + temp);
    writeComment("DEBUG - radius = " + moveLength.radius);
  }
  return moveLength;
}
// End of multi-axis feedrate logic

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  var directionCode;
  if (currentSection.spindle == SPINDLE_PRIMARY) {
    directionCode = clockwise ? 2 : 3;
  } else {
    directionCode = clockwise ? 3 : 2;
  }
  if (machineState.useXZCMode) {
    switch (getCircularPlane()) {
    case PLANE_ZX:
      if (!isSpiral()) {
        var c = getCClosest(x, y, cOutput.getCurrent());
        if (!cFormat.areDifferent(c, cOutput.getCurrent())) {
          validate(getCircularSweep() < Math.PI, localize("Circular sweep exceeds limit."));
          var start = getCurrentPosition();
          writeBlock(gPlaneModal.format(18), gMotionModal.format(directionCode), xOutput.format(getModulus(x, y)), cOutput.format(c), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
          previousABC.setZ(c);
          return;
        }
      }
      break;
    case PLANE_XY:
      var d2 = center.x * center.x + center.y * center.y;
      if (d2 < 1e-18) { // center is on rotary axis
        var c = getCClosest(x, y, cOutput.getCurrent(), clockwise);
        writeBlock(gMotionModal.format(1), xOutput.format(getModulus(x, y)), cOutput.format(c), zOutput.format(z), getFeed(feed));
        previousABC.setZ(c);
        return;
      }
      break;
    }

    linearize(getTolerance());
    return;
  }

  if (isSpeedFeedSynchronizationActive()) {
    error(localize("Speed-feed synchronization is not supported for circular moves."));
    return;
  }

  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (getProperty("useRadius") || isHelical()) { // radius mode does not support full arcs
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(getG17Code()), gMotionModal.format(directionCode), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(18), gMotionModal.format(directionCode), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(19), gMotionModal.format(directionCode), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else if (!getProperty("useRadius")) {
    if (isHelical() && ((getCircularSweep() < toRad(30)) || (getHelicalPitch() > 10))) { // avoid G112 issue
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(getG17Code()), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(18), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(19), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else { // use radius mode
    if (isHelical() && ((getCircularSweep() < toRad(30)) || (getHelicalPitch() > 10))) {
      linearize(tolerance);
      return;
    }
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      r = -r; // allow up to <360 deg arcs
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(getG17Code()), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_ZX:
      if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(18), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_YZ:
      if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(19), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

function onCycle() {
  if ((typeof isSubSpindleCycle == "function") && isSubSpindleCycle(cycleType)) {
    writeln("");
    if (hasParameter("operation-comment")) {
      var comment = getParameter("operation-comment");
      if (comment) {
        writeComment(comment);
      }
    }
    // Start of stock transfer operation(s)
    if (!stockTransferIsActive) {
      onCommand(COMMAND_STOP_SPINDLE);
      onCommand(COMMAND_COOLANT_OFF);
      if (gotSecondarySpindle && previousPartSpindle == SPINDLE_SUB) {
        writeBlock(gFormat.format(111), formatComment("Cross Axis Control cancel"));
      }
    
      if (cycleType != "secondary-spindle-return") {
        writeBlock(gMotionModal.format(0), gFormat.format(53), barOutput.format(0)); // retract Sub Spindle
        goHome();
        if (getProperty("optionalStop")) {
          onCommand(COMMAND_OPTIONAL_STOP);
          gMotionModal.reset();
        }
      }
      writeln("");
      gSelectSpindleModal.reset();
      writeBlock("T" + getProperty("transferTool"));
      writeBlock(gMotionModal.format(0), "Z0", formatComment("CLEAR"));
      forceUnlockMultiAxis();
      //onCommand(COMMAND_UNLOCK_MULTI_AXIS);

      if (cycle.stopSpindle) {
        cAxisEngageModal.reset();
        forceABC();
        gMotionModal.reset();
        writeBlock(feedMode, gPlaneModal.format(18));
        writeBlock(mFormat.format(getCode("ACTIVATE_SPINDLE", getSpindle(true))));
        writeBlock(cAxisEngageModal.format(getCode("ENABLE_C_AXIS", getSpindle(true))),
          formatComment("C1 AXIS ON"));
        writeBlock(gMotionModal.format(0), cOutput.format(0), formatComment("MAIN ANGLE"));
        writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(true))),
          formatComment("C1 axis off"));
        writeBlock(mFormat.format(getCode("ACTIVATE_SPINDLE", SPINDLE_SUB)));
        writeBlock(cAxisEngageModal.format(getCode("ENABLE_C_AXIS", SPINDLE_SUB)),
          formatComment("C2 AXIS ON"));
        writeBlock(gFormat.format(110), "C2", formatComment("Cross Axis Control"));
        gMotionModal.reset();
        forceABC();
        writeBlock(gMotionModal.format(0), cOutput.format(cycle.spindleOrientation), formatComment("SUB ANGLE"));
        writeBlock(gFormat.format(111), formatComment("Cross Axis Control Cancel"));
        gMotionModal.reset();
        writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", SPINDLE_SUB)),
          formatComment("C2 axis off"));
        writeBlock(mFormat.format(getCode("ACTIVATE_SPINDLE", getSpindle(true))));
      }
      gFeedModeModal.reset();
      var feedMode;
      if (currentSection.feedMode == FEED_PER_REVOLUTION) {
        feedMode = gFeedModeModal.format(getCode("FEED_MODE_MM_REV", getSpindle(false)));
      } else {
        feedMode = gFeedModeModal.format(getCode("FEED_MODE_MM_MIN", getSpindle(false)));
      }
      gPlaneModal.reset();
      if (!getProperty("optimizeCaxisSelect")) {
        cAxisEngageModal.reset();
      }
    }
    
    switch (cycleType) {
    case "secondary-spindle-return":
      var secondaryPull = false;
      var secondaryHome = false;
      // Transfer part to secondary spindle
      if (cycle.unclampMode != "keep-clamped") {
        secondaryPull = true;
        secondaryHome = true;
      } else {
        // pull part only (when offset!=0), Return secondary spindle to home (when offset=0)
        if (hasParameter("operation:feedPlaneHeight_offset")) { // Inventor
          secondaryPull = getParameter("operation:feedPlaneHeight_offset") != 0;
        }
        if (hasParameter("operation:feedPlaneHeightOffset")) { // HSMWorks
          secondaryPull = getParameter("operation:feedPlaneHeightOffset") != 0;
        }
        secondaryHome = !secondaryPull;
      }

      if (secondaryPull) {
        writeBlock(mFormat.format(getCode("UNCLAMP_CHUCK", getSpindle(true))), formatComment("UNCLAMP MAIN CHUCK"));
        onDwell(cycle.dwell);
        writeBlock(conditional(cycle.useMachineFrame, gFormat.format(53)), gMotionModal.format(1),
          subBOutput.format(subSupport) + subBFormat.format(cycle.feedPosition) + "]",
          getFeed(cycle.feedrate),
          formatComment("BAR PULL")
        );
      }
      if (secondaryHome) {
        if (cycle.unclampMode == "unclamp-secondary") { // simple bar pulling operation
          writeBlock(mFormat.format(getCode("CLAMP_CHUCK", getSpindle(true))), formatComment("CLAMP MAIN CHUCK"));
          onDwell(1);
          writeBlock(mFormat.format(getCode("UNCLAMP_CHUCK", getSecondarySpindle())), formatComment("UNCLAMP SUB CHUCK"));
          onDwell(1);
        }
        writeBlock(mFormat.format(541), formatComment("Transfer Mode Cancel"));
        writeBlock(gMotionModal.format(0), gFormat.format(53), barOutput.format(0), formatComment("SUB SPINDLE RETURN"));
        writeBlock(gFeedModeModal.format(99));
        if (transferType == TRANSFER_SPEED) {
          writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_SPEED_OFF", getSpindle(true))), formatComment("SYNCRHONIZATION OFF"));
        } else if (transferType == TRANSFER_PHASE) {
          writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_SPEED_OFF", getSpindle(true))), formatComment("SYNCRHONIZATION OFF"));
          writeBlock(mFormat.format(getCode("STOP_SPINDLE", SPINDLE_SUB)), formatComment("SUB SPINDLE STOP"));
        }
        stockTransferIsActive = false;
      } else {
        writeBlock(mFormat.format(getCode("CLAMP_CHUCK", getSpindle(true))), formatComment("CLAMP MAIN CHUCK"));
        onDwell(cycle.dwell);
        stockTransferIsActive = true;
      }
      break;
    case "secondary-spindle-pull":
      writeBlock(gMotionModal.format(1), barOutput.format(cycle.pullingDistance), getFeed(cycle.feedrate));
      writeBlock(mFormat.format(getCode("CLAMP_CHUCK", getSpindle(true))));
      stockTransferIsActive = true;
      break;
    case "secondary-spindle-grab":
      if (currentSection.partCatcher) {
        engagePartCatcher(true);
      }
      /*writeBlock(mFormat.format(getCode("INTERLOCK_BYPASS", getSecondarySpindle())), formatComment("INTERLOCK BYPASS"));*/
    
      writeBlock(mFormat.format(getCode("UNCLAMP_CHUCK", getSecondarySpindle())), formatComment("UNCLAMP SUB CHUCK"));

      onDwell(cycle.dwell);
      gSpindleModeModal.reset();
      if (currentSection.partCatcher) {
        writeBlock(mFormat.format(getCode("PART_CATCHER_OFF", true)), formatComment(localize("PART CATCHER OFF")));
      }
      if (airCleanChuck) {
      // clean out chips
        writeBlock(mFormat.format(getCode("COOLANT_AIR_ON", getSpindle(true))), formatComment("MAIN SPINDLE AIR BLOW ON"));
        onDwell(1);
        writeBlock(mFormat.format(getCode("COOLANT_AIR_OFF", getSpindle(true))), formatComment("MAIN SPINDLE AIR BLOW OFF"));
        onDwell(1);
        writeBlock(mFormat.format(getCode("COOLANT_AIR_ON", getSecondarySpindle())), formatComment("SUB SPINDLE AIR BLOW ON"));
        onDwell(1);
        writeBlock(mFormat.format(getCode("COOLANT_AIR_OFF", getSecondarySpindle())), formatComment("SUB SPINDLE AIR BLOW OFF"));
        onDwell(1);
      }
      if (cycle.stopSpindle) { // no spindle rotation
        /*writeBlock(
          mFormat.format(getCode("ORIENT_SPINDLE", getSpindle(true))),
          mFormat.format(getCode("ORIENT_SPINDLE", getSecondarySpindle())),
          formatComment("SPINDLE ORIENTATION")
        );*/
      } else if (transferType == TRANSFER_SPEED) { // speed synchronization
        // start synchronization
        writeBlock(gSelectSpindleModal.format(getCode("ACTIVATE_SPINDLE", getSpindle(true))));
        writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(true))));
        writeBlock(
          gSpindleModeModal.format(97),
          sOutput.format(cycle.spindleSpeed),
          mFormat.format(getCode("START_SPINDLE_CW", getSpindle(true))));
        writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_SPEED")), formatComment("SPEED SYNCHRONIZATION"));
        //writeBlock(gFormat.format(53), "H" + abcFormat.format(0), formatComment("REFERENCE RETURN OF C"));
        //writeBlock(mFormat.format(60), formatComment("PARKING MAIN SPINDLE"));
      } else { // phase syncronization
        writeBlock(mFormat.format(getCode("STOP_SPINDLE", SPINDLE_MAIN)), formatComment("MAIN SPINDLE STOP"));
        writeBlock(mFormat.format(getCode("STOP_SPINDLE", SPINDLE_SUB)), formatComment("SUB SPINDLE STOP"));
        writeBlock(gSelectSpindleModal.format(getCode("ACTIVATE_SPINDLE", getSpindle(true))));
        writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(true))));
        writeBlock(
          gSpindleModeModal.format(97),
          sOutput.format(cycle.spindleSpeed),
          mFormat.format(getCode("START_SPINDLE_CW", getSpindle(true))));

        writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_PHASE")), formatComment("PHASE SYNCHRONIZATION"));
      }

      writeBlock(mFormat.format(540), formatComment("Transfer Mode on"));

      // approach part
      gMotionModal.reset();

      writeBlock(conditional(cycle.useMachineFrame, gFormat.format(53)), gMotionModal.format(0), subBOutput.format(cycle.feedPosition) + "]", formatComment("MOVE HD2 TO APPROACH"));
      //For possible pull operation
      subSupport = cycle.chuckPosition;
      if (transferUseTorque) { //G31 Mode
        writeBlock("#3030=70", formatComment("THRUST FACTOR"));
        writeBlock(mFormat.format(getCode("TORQUE_SKIP_ON", getSpindle(true))), formatComment("PUSH PRESS ON"));
        writeBlock(conditional(cycle.useMachineFrame, gFormat.format(53)), gMotionModal.format(31), subBOutput.format(cycle.chuckPosition) + "]", getFeed(cycle.feedrate), formatComment("G31 PUSH"));
        writeBlock(mFormat.format(getCode("TORQUE_SKIP_OFF", getSpindle(true))), formatComment("PUSH PRESS OFF"));
      } else {
        writeBlock(conditional(cycle.useMachineFrame, gFormat.format(53)), gMotionModal.format(1), subBOutput.format(cycle.chuckPosition) + "]", getFeed(cycle.feedrate));
      }
      gMotionModal.reset();
      writeBlock(mFormat.format(getCode("CLAMP_CHUCK", getSecondarySpindle())), formatComment("CLAMP SUB CHUCK"));
      writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_SPEED")), formatComment("SPEED SYNCHRONIZATION"));
      onDwell(1);
      stockTransferIsActive = true;
      break;
    }
  }

  if (cycleType == "stock-transfer") {
    warning(localize("Stock transfer is not supported. Required machine specific customization."));
    return;
  } else if (!getProperty("useCycles") && tapping) {
    startSpindle(false, false);
  }
}

var saveShowSequenceNumbers = true;
var pathBlockNumber = {start: 0, end: 0};
var isCannedCycle = false;

function onCyclePath() {
  saveShowSequenceNumbers = showSequenceNumbers;
  // buffer all paths and stop feeds being output
  feedOutput.disable();
  showSequenceNumbers = false;
  redirectToBuffer();
  gMotionModal.reset();
  isCannedCycle = true;
  xOutput.reset();
  zOutput.reset();
}

function onCyclePathEnd() {
  showSequenceNumbers = saveShowSequenceNumbers; // reset property to initial state
  feedOutput.enable();
  var cyclePath = String(getRedirectionBuffer()).split(EOL); // get cycle path from buffer
  closeRedirection();
  for (line in cyclePath) { // remove empty elements
    if (cyclePath[line] == "") {
      cyclePath.splice(line);
    }
  }

  var verticalPasses;
  if (cycle.profileRoughingCycle == 0) {
    verticalPasses = false;
  } else if (cycle.profileRoughingCycle == 1) {
    verticalPasses = true;
  } else {
    error(localize("Unsupported passes type."));
    return;
  }
  // output cycle data
  switch (cycleType) {
  case "turning-canned-rough":
    if (getProperty("controllerType") == "Matrix" || getProperty("controllerType") == "Smooth") {
      writeBlock(gFormat.format(verticalPasses ? 72 : 71),
        (verticalPasses ? "W" : "U") + spatialFormat.format(cycle.depthOfCut),
        "R" + spatialFormat.format(cycle.retractLength)
      );
      writeBlock(gFormat.format(verticalPasses ? 72 : 71),
        "P" + (getStartEndSequenceNumber(cyclePath, true)),
        "Q" + (getStartEndSequenceNumber(cyclePath, false)),
        "U" + xFormat.format(cycle.xStockToLeave),
        "W" + spatialFormat.format(cycle.zStockToLeave),
        getFeed(cycle.cutfeedrate)
      );
    } else {
      writeBlock(gFormat.format(verticalPasses ? 72 : 71),
        "P" + (getStartEndSequenceNumber(cyclePath, true)),
        "Q" + (getStartEndSequenceNumber(cyclePath, false)),
        "U" + xFormat.format(cycle.xStockToLeave),
        "W" + spatialFormat.format(cycle.zStockToLeave),
        "D" + spatialFormat.format(cycle.depthOfCut),
        getFeed(cycle.cutfeedrate)
      );
    }
    break;
  default:
    error(localize("Unsupported turning canned cycle."));
  }
  
  for (var i = 0; i < cyclePath.length; ++i) {
    if (i == 0 || i == (cyclePath.length - 1)) { // write sequence number on first and last line of the cycle path
      showSequenceNumbers = true;
      if ((i == 0 && pathBlockNumber.start != sequenceNumber) || (i == (cyclePath.length - 1) && pathBlockNumber.end != sequenceNumber)) {
        error(localize("Mismatch of start/end block number in turning canned cycle."));
        return;
      }
    }
    writeBlock(cyclePath[i]); // output cycle path
    showSequenceNumbers = saveShowSequenceNumbers; // reset property to initial state
    isCannedCycle = false;
  }
}

function getStartEndSequenceNumber(cyclePath, start) {
  if (start) {
    pathBlockNumber.start = sequenceNumber + conditional(saveShowSequenceNumbers, getProperty("sequenceNumberIncrement"));
    return pathBlockNumber.start;
  } else {
    pathBlockNumber.end = sequenceNumber + getProperty("sequenceNumberIncrement") + conditional(saveShowSequenceNumbers, (cyclePath.length - 1) * getProperty("sequenceNumberIncrement"));
    return pathBlockNumber.end;
  }
}

function getCommonCycle(x, y, z, r, includeRcode) {

  // R-value is incremental position from current position
  var raptoS = "";
  if ((r !== undefined) && includeRcode) {
    raptoS = "R" + spatialFormat.format(r);
  }

  if (machineState.useXZCMode) {
    cOutput.reset();
    return [xOutput.format(getModulus(x, y)), cOutput.format(getCClosest(x, y, cOutput.getCurrent())),
      zOutput.format(z),
      raptoS];
  } else {
    return [xOutput.format(x), yOutput.format(y),
      zOutput.format(z),
      raptoS];
  }
}

function writeCycleClearance(plane, clearance) {
  var currentPosition = getCurrentPosition();
  if (true) {
    onCycleEnd();
    switch (plane) {
    case 17:
      writeBlock(gMotionModal.format(0), zOutput.format(clearance));
      break;
    case 18:
      writeBlock(gMotionModal.format(0), yOutput.format(clearance));
      break;
    case 19:
      writeBlock(gMotionModal.format(0), xOutput.format(clearance));
      break;
    default:
      error(localize("Unsupported drilling orientation."));
      return;
    }
  }
}

var threadStart;
var threadEnd;
function moveToThreadStart(x, y, z) {
  var cuttingAngle = 0;
  if (hasParameter("operation:infeedAngle")) {
    cuttingAngle = getParameter("operation:infeedAngle");
  }
  if (cuttingAngle != 0) {
    var zz;
    if (isFirstCyclePoint()) {
      threadStart = getCurrentPosition();
      threadEnd = new Vector(x, y, z);
    } else {
      var zz = threadStart.z - (Math.abs(threadEnd.x - x) * Math.tan(toRad(cuttingAngle)));
      writeBlock(gMotionModal.format(0), zOutput.format(zz));
      threadStart.setZ(zz);
      threadEnd = new Vector(x, y, z);
    }
  }
}

function onCyclePoint(x, y, z) {

  if (!getProperty("useCycles") || currentSection.isMultiAxis()) {
    expandCyclePoint(x, y, z);
    return;
  }

  var plane = gPlaneModal.getCurrent();
  var localZOutput = zOutput;
  if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1)) ||
      isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, -1))) {
    plane = 17; // XY plane
    localZOutput = zOutput;
  } else if (Vector.dot(currentSection.workPlane.forward, new Vector(0, 0, 1)) < 1e-7) {
    plane = 19; // YZ plane
    localZOutput = xOutput;
  } else {
    expandCyclePoint(x, y, z);
    return;
  }

  switch (cycleType) {
  case "thread-turning":
    if (getProperty("useSimpleThread") ||
      (hasParameter("operation:doMultipleThreads") && (getParameter("operation:doMultipleThreads") != 0)) ||
      (hasParameter("operation:infeedMode") && (getParameter("operation:infeedMode") != "constant"))) {
      var r = -cycle.incrementalX; // positive if taper goes down - delta radius
      moveToThreadStart(x, y, z);
      xOutput.reset();
      zOutput.reset();
      writeBlock(
        gMotionModal.format(92),
        xOutput.format(x),
        yOutput.format(y),
        zOutput.format(z),
        conditional(zFormat.isSignificant(r), g92ROutput.format(r)),
        pitchOutput.format(cycle.pitch)
      );
    } else {
      if (isLastCyclePoint()) {
        // thread height and depth of cut
        var threadHeight = getParameter("operation:threadDepth");
        var firstDepthOfCut = threadHeight / getParameter("operation:numberOfStepdowns");
     
        // first G76 block
        var repeatPass = hasParameter("operation:nullPass") ? getParameter("operation:nullPass") : 0;
        var chamferWidth = 10; // Pullout-width is 1*thread-lead in 1/10's;
        var materialAllowance = 0; // Material allowance for finishing pass
        var cuttingAngle = 60; // Angle is not stored with tool. toDeg(tool.getTaperAngle());
        if (hasParameter("operation:infeedAngle")) {
          cuttingAngle = getParameter("operation:infeedAngle");
        }
        var pcode = repeatPass * 10000 + chamferWidth * 100 + cuttingAngle;
        gCycleModal.reset();
       
        if (getProperty("controllerType") == "Matrix" || getProperty("controllerType") == "Smooth") {
          writeBlock(
            gCycleModal.format(76),
            threadP1Output.format(pcode),
            threadQOutput.format(firstDepthOfCut),
            threadROutput.format(materialAllowance)
          );
          // second G76 block
          var r = -cycle.incrementalX; // positive if taper goes down - delta radius
          gCycleModal.reset();
          writeBlock(
            gCycleModal.format(76),
            xOutput.format(x),
            zOutput.format(z),
            conditional(zFormat.isSignificant(r), threadROutput.format(r)),
            threadP2Output.format(threadHeight),
            threadQOutput.format(firstDepthOfCut),
            pitchOutput.format(cycle.pitch)
          );
        } else {
          var i = -cycle.incrementalX;
          writeBlock(
            gCycleModal.format(76),
            xOutput.format(x),
            zOutput.format(z),
            "K" + (threadHeight),
            "D" + (firstDepthOfCut),
            "A" + (cuttingAngle),
            (threadIOutput.format(i)),
            pitchOutput.format(cycle.pitch)
          );
        }
      }
    }
    forceFeed();
    return;
  }

  // clamp the C-axis if necessary
  // the C-axis is automatically unclamped by the controllers during cycles
  var lockCode = "";
  if (!machineState.axialCenterDrilling && !machineState.isTurningOperation) {
    lockCode = mFormat.format(getCode("LOCK_MULTI_AXIS", getSpindle(true)));
  }

  var rapto = 0;
  if (isFirstCyclePoint()) { // first cycle point
    rapto = cycle.retract - cycle.clearance;

    var F = (gFeedModeModal.getCurrent() == 99 ? cycle.feedrate / spindleSpeed : cycle.feedrate);
    var P = !cycle.dwell ? 0 : clamp(1, cycle.dwell * 1000, 99999999); // in milliseconds
    
    switch (cycleType) {
    case "drilling":
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      writeBlock(
        gCycleModal.format(plane == 19 ? 87 : 83),
        getCommonCycle(x, y, z, rapto, true),
        conditional(P > 0, pOutput.format(P)),
        feedOutput.format(F),
        lockCode
      );
      break;
    case "chip-breaking":
    case "deep-drilling":
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      writeBlock(
        gCycleModal.format(plane == 19 ? 87 : 83),
        getCommonCycle(x, y, z, rapto, true),
        conditional(cycle.incrementalDepth > 0, qOutput.format(cycle.incrementalDepth)),
        conditional(P > 0, pOutput.format(P)),
        feedOutput.format(F),
        lockCode
      );
      break;
    case "tapping":
    case "right-tapping":
    case "left-tapping":
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      if (!F) {
        F = tool.getTappingFeedrate();
      }
      //startSpindle(true, false);
      if (getProperty("useRigidTapping")) {
        writeBlock(
          gCycleModal.format(plane == 19 ? 88.2 : 84.2),
          getCommonCycle(x, y, z, rapto, true),
          pitchOutput.format(F),
          lockCode
        );
      } else {
        writeBlock(
          gCycleModal.format(plane == 19 ? 88 : 84),
          getCommonCycle(x, y, z, rapto, true),
          pitchOutput.format(F),
          lockCode
        );
      }
      break;
    case "boring":
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      writeBlock(
        gCycleModal.format(plane == 19 ? 89 : 85),
        getCommonCycle(x, y, z, rapto, true),
        conditional(P > 0, pOutput.format(P)),
        feedOutput.format(F),
        lockCode
      );
      break;
    default:
      expandCyclePoint(x, y, z);
    }
  } else { // position to subsequent cycle points
    if (cycleExpanded) {
      expandCyclePoint(x, y, z);
    } else {
      var step = 0;
      if (cycleType == "chip-breaking" || cycleType == "deep-drilling") {
        step = cycle.incrementalDepth;
      }
      writeBlock(getCommonCycle(x, y, z, rapto, false), conditional(step > 0, qOutput.format(step)), lockCode);
    }
  }
}

function onCycleEnd() {
  if (!cycleExpanded && !stockTransferIsActive) {
    writeBlock(gCycleModal.format(80));
    gMotionModal.reset();
  }
}

function onPassThrough(text) {
  writeBlock(text);
}

function onParameter(name, value) {
  var invalid = false;
  switch (name) {
  case "action":
    if (String(value).toUpperCase() == "PARTEJECT") {
      ejectRoutine = true;
    } else if (String(value).toUpperCase() == "USEXZCMODE") {
      forceXZCMode = true;
      forcePolarMode = false;
    } else if (String(value).toUpperCase() == "USEPOLARMODE") {
      forcePolarMode = true;
      forceXZCMode = false;
    } else {
      var sText1 = String(value);
      var sText2 = new Array();
      sText2 = sText1.split(":");
      if (sText2.length != 2) {
        error(localize("Invalid action command: ") + value);
        return;
      }
      if (sText2[0].toUpperCase() == "TRANSFERTYPE") {
        transferType = parseToggle(sText2[1], "PHASE", "SPEED");
        if (transferType == undefined) {
          error(localize("TransferType must be Phase or Speed"));
          return;
        }
      } else if (sText2[0].toUpperCase() == "TRANSFERUSETORQUE") {
        transferUseTorque = parseToggle(sText2[1], "YES", "NO");
        if (transferUseTorque == undefined) {
          invalid = true;
        }
      } else {
        invalid = true;
      }
    }
  }
  if (invalid) {
    error(localize("Invalid action parameter: ") + sText2[0] + ":" + sText2[1]);
    return;
  }
}

function parseToggle() {
  var stat = undefined;
  for (i = 1; i < arguments.length; i++) {
    if (String(arguments[0]).toUpperCase() == String(arguments[i]).toUpperCase()) {
      if (String(arguments[i]).toUpperCase() == "YES") {
        stat = true;
      } else if (String(arguments[i]).toUpperCase() == "NO") {
        stat = false;
      } else {
        stat = i - 1;
        break;
      }
    }
  }
  return stat;
}

var currentCoolantMode = COOLANT_OFF;
function setCoolant(coolant) {
  if (coolant == currentCoolantMode) {
    return; // coolant is already active
  }

  var m = undefined;
  var m1 = undefined;
  if (coolant == COOLANT_OFF) {
    if (currentCoolantMode == COOLANT_THROUGH_TOOL) {
      m = getCode("COOLANT_THROUGH_TOOL_OFF", getSpindle(true));
    } else if (currentCoolantMode == COOLANT_AIR) {
      m = getCode("COOLANT_AIR_OFF", getSpindle(true));
    } else if (currentCoolantMode == COOLANT_FLOOD) {
      m = getCode("COOLANT_FLOOD_OFF", getSpindle(true));
    } else {
      m = getCode("COOLANT_OFF", getSpindle(true));
    }
    writeBlock(mFormat.format(m));
    currentCoolantMode = COOLANT_OFF;
    return;
  }
  if ((currentCoolantMode != COOLANT_OFF) && (coolant != currentCoolantMode)) {
    setCoolant(COOLANT_OFF);
  }

  switch (coolant) {
  case COOLANT_FLOOD:
    m = getCode("COOLANT_FLOOD_ON", getSpindle(true));
    break;
  case COOLANT_THROUGH_TOOL:
    m = getCode("COOLANT_THROUGH_TOOL_ON", getSpindle(true));
    break;
  case COOLANT_AIR:
    m = getCode("COOLANT_AIR_ON", getSpindle(true));
    break;
  case COOLANT_FLOOD_THROUGH_TOOL:
    m = getCode("COOLANT_THROUGH_TOOL_ON", getSpindle(true));
    m1 = getCode("COOLANT_FLOOD_ON", getSpindle(true));
    break;
  default:
    warning(localize("Coolant not supported."));
    if (currentCoolantMode == COOLANT_OFF) {
      return;
    }
    coolant = COOLANT_OFF;
    m = getCode("COOLANT_OFF", getSpindle(true));
  }

  if (m1) {
    writeBlock(mFormat.format(m), mFormat.format(m1));
  } else {
    writeBlock(mFormat.format(m));
  }
  currentCoolantMode = coolant;
}

function isSpindleSpeedDifferent() {
  if (isFirstSection()) {
    return true;
  }
  if (getPreviousSection().getTool().clockwise != tool.clockwise) {
    return true;
  }
  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    if ((getPreviousSection().getTool().getSpindleMode() != SPINDLE_CONSTANT_SURFACE_SPEED) ||
        rpmFormat.areDifferent(getPreviousSection().getTool().surfaceSpeed, tool.surfaceSpeed)) {
      return true;
    }
  } else {
    if ((getPreviousSection().getTool().getSpindleMode() != SPINDLE_CONSTANT_SPINDLE_SPEED) ||
        rpmFormat.areDifferent(getPreviousSection().getTool().spindleRPM, spindleSpeed)) {
      return true;
    }
  }
  return false;
}

function onSpindleSpeed(spindleSpeed) {
  if (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) {
    startSpindle(false, false, getFramePosition(currentSection.getInitialPosition()), spindleSpeed);
  }
}

function startSpindle(tappingMode, forceRPMMode, initialPosition, rpm) {
  var spindleDir;
  var spindleMode;
  var _spindleSpeed = spindleSpeed;
  if (rpm !== undefined) {
    _spindleSpeed = rpm;
  }

  gSpindleModeModal.reset();
  
  if ((getSpindle(true) == SPINDLE_SUB) && !gotSecondarySpindle) {
    error(localize("Secondary spindle is not available."));
    return;
  }
  
  if (tappingMode) {
    spindleDir = mFormat.format(getCode("RIGID_TAPPING", getSpindle(false)));
  } else {
    spindleDir = mFormat.format(tool.clockwise ? getCode("START_SPINDLE_CW", getSpindle(false)) : getCode("START_SPINDLE_CCW", getSpindle(false)));
  }

  var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, getProperty("maximumSpindleSpeed")) : getProperty("maximumSpindleSpeed");
  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    _spindleSpeed = tool.surfaceSpeed * ((unit == MM) ? 1 / 1000.0 : 1 / 12.0);
    if (forceRPMMode) { // RPM mode is forced until move to initial position
      if (xFormat.getResultingValue(initialPosition.x) == 0) {
        _spindleSpeed = maximumSpindleSpeed;
      } else {
        _spindleSpeed = Math.min((_spindleSpeed * ((unit == MM) ? 1000.0 : 12.0) / (Math.PI * Math.abs(initialPosition.x * 2))), maximumSpindleSpeed);
      }
      spindleMode = getCode("CONSTANT_SURFACE_SPEED_OFF", getSpindle(false));
    } else {
      spindleMode = getCode("CONSTANT_SURFACE_SPEED_ON", getSpindle(false));
    }
  } else {
    spindleMode = getCode("CONSTANT_SURFACE_SPEED_OFF", getSpindle(false));
  }

  if (machineState.isTurningOperation || machineState.axialCenterDrilling) {
    writeBlock(
      gSpindleModeModal.format(spindleMode),
      sOutput.format(_spindleSpeed),
      spindleDir,
      rcssOutput.format(getCode("SELECT_SPINDLE", getSpindle(true)))
    );
  } else {
    writeBlock(
      gSpindleModeModal.format(spindleMode),
      sOutput.format(_spindleSpeed),
      spindleDir
    );
  }
  // wait for spindle here if required
}

function onCommand(command) {
  switch (command) {
  case COMMAND_COOLANT_OFF:
    setCoolant(COOLANT_OFF);
    break;
  case COMMAND_COOLANT_ON:
    setCoolant(COOLANT_FLOOD);
    break;
  case COMMAND_LOCK_MULTI_AXIS:
    writeBlock(cAxisBrakeModal.format(getCode("LOCK_MULTI_AXIS", getSpindle(true))));
    break;
  case COMMAND_UNLOCK_MULTI_AXIS:
    writeBlock(cAxisBrakeModal.format(getCode("UNLOCK_MULTI_AXIS", getSpindle(true))));
    break;
  case COMMAND_OPEN_DOOR:
    if (gotDoorControl) {
      writeBlock(mFormat.format(24)); // optional
    }
    break;
  case COMMAND_CLOSE_DOOR:
    if (gotDoorControl) {
      writeBlock(mFormat.format(25)); // optional
    }
    break;
  case COMMAND_BREAK_CONTROL:
    break;
  case COMMAND_TOOL_MEASURE:
    break;
  case COMMAND_ACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_DEACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    break;
  case COMMAND_OPTIONAL_STOP:
    writeBlock(mFormat.format(1));
    break;
  case COMMAND_END:
    writeBlock(mFormat.format(2));
    break;
  case COMMAND_STOP_SPINDLE:
    writeBlock(
      mFormat.format(getCode("STOP_SPINDLE", activeSpindle))
      //pOutput.format(getCode("SELECT_SPINDLE", activeSpindle))
    );
    sOutput.reset();
    break;
  case COMMAND_START_SPINDLE:
    startSpindle(false, true, false, spindleSpeed);
    return;
  case COMMAND_ORIENTATE_SPINDLE:
    if (machineState.isTurningOperation || machineState.axialCenterDrilling) {
      writeBlock(mFormat.format(getCode("ORIENT_SPINDLE", getSpindle(true))));
    } else {
      error(localize("Spindle orientation is not supported for live tooling."));
      return;
    }
    break;
  case COMMAND_SPINDLE_CLOCKWISE:
    writeBlock(mFormat.format(getCode("START_SPINDLE_CW", getSpindle(false))));
    break;
  case COMMAND_SPINDLE_COUNTERCLOCKWISE:
    writeBlock(mFormat.format(getCode("START_SPINDLE_CCW", getSpindle(false))));
    break;
  // case COMMAND_CLAMP: // add support for clamping
  // case COMMAND_UNCLAMP: // add support for clamping
  default:
    onUnsupportedCommand(command);
  }
}

/** Returns the next used tool past the transfer operations. */
function getNextTool() {
  var nextTool = 0;
  var numberOfSections = getNumberOfSections();
  for (var i = getNextSection().getId(); i < numberOfSections; ++i) {
    var section = getSection(i);
    if (!section.hasCycle("secondary-spindle-grab") && !section.hasCycle("secondary-spindle-return")) {
      nextTool = section.getTool().number;
      break;
    }
  }
  return nextTool;
}

function getG17Code() {
  return machineState.usePolarMode ? 17 : 17;
}

function ejectPart() {
  gMotionModal.reset();
  writeBlock(cAxisBrakeModal.format(getCode("UNLOCK_MULTI_AXIS", previousPartSpindle)));
  if (gotSecondarySpindle && previousPartSpindle == SPINDLE_SUB) {
    writeBlock(gFormat.format(111), formatComment("Cross Axis Control cancel"));
  }
  goHome(); // Position all axes to home position
  //writeBlock(mFormat.format(getCode("UNLOCK_MULTI_AXIS", getSpindle(true))));
  if (!getProperty("optimizeCaxisSelect")) {
    cAxisEngageModal.reset();
  }
  if (getProperty("optionalStop")) {
    onCommand(COMMAND_OPTIONAL_STOP);
    gMotionModal.reset();
  }
  writeln("");
  if (getProperty("sequenceNumberToolOnly")) {
    writeCommentSeqno(localize("PART EJECT"));
  } else {
    writeComment(localize("PART EJECT"));
  }
  writeBlock(gMotionModal.format(0), gFormat.format(28), barOutput.format(0)); // retract bar feeder
  writeBlock(mFormat.format(getCode("ACTIVATE_SPINDLE", SPINDLE_SUB)));
  writeBlock(
    gFeedModeModal.format(getCode("FEED_MODE_MM_MIN", getSpindle(false))),
    gPlaneModal.format(getG17Code()),
    cAxisEngageModal.format(getCode("DISABLE_C_AXIS", SPINDLE_SUB))
  );
  //setCoolant(COOLANT_THROUGH_TOOL);
  gSpindleModeModal.reset();
  writeBlock(
    gSpindleModeModal.format(getCode("CONSTANT_SURFACE_SPEED_OFF", getSpindle(false))),
    sOutput.format(50),
    mFormat.format(getCode("START_SPINDLE_CW", SPINDLE_SUB))
  );
  //writeBlock(mFormat.format(getCode("INTERLOCK_BYPASS", getSpindle(true))));
  if (getProperty("gotPartCatcher")) {
    writeBlock(mFormat.format(getCode("PART_CATCHER_ON", getSpindle(true))));
    onDwell(1.1);
  }
  if (airCleanChuck) {
    writeBlock(mFormat.format(358), formatComment("AIR BLAST"));
  }
  writeBlock(mFormat.format(getCode("UNCLAMP_CHUCK", getSecondarySpindle())), formatComment("UNCLAMP SUB CHUCK"));
  onDwell(1.5);
  //writeBlock(mFormat.format(getCode("CYCLE_PART_EJECTOR")));
  //onDwell(0.5);
  if (getProperty("gotPartCatcher")) {
    writeBlock(mFormat.format(getCode("PART_CATCHER_OFF", getSpindle(true))));
    onDwell(1.1);
  }
  // clean out chips
  if (airCleanChuck) {
    writeBlock(mFormat.format(getCode("COOLANT_AIR_ON", getSpindle(true))));
    onDwell(2.5);
    writeBlock(mFormat.format(getCode("COOLANT_AIR_OFF", getSpindle(true))));
  }
  writeBlock(mFormat.format(getCode("STOP_SPINDLE", SPINDLE_SUB))/*, pOutput.format(getCode("SELECT_SPINDLE", getSpindle(true)))*/);
  setCoolant(COOLANT_OFF);
  if (getProperty("optionalStop")) {
    onCommand(COMMAND_OPTIONAL_STOP);
    gMotionModal.reset();
  }
  writeComment(localize("END OF PART EJECT"));
  //writeln("");
  ejectRoutine = false;
}

function engagePartCatcher(engage) {
  if (getProperty("gotPartCatcher")) {
    if (engage) { // engage part catcher
      writeBlock(mFormat.format(getCode("PART_CATCHER_ON", true)), formatComment(localize("PART CATCHER ON")));
    } else { // disengage part catcher
      onCommand(COMMAND_COOLANT_OFF);
      writeBlock(mFormat.format(getCode("PART_CATCHER_OFF", true)), formatComment(localize("PART CATCHER OFF")));
    }
  }
}

function onSectionEnd() {

  if (machineState.usePolarMode) {
    setPolarMode(false); // disable polar interpolation mode
  }

  // cancel SFM mode to preserve spindle speed
  //  if ((tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) && !stockTransferIsActive) {
  //    startSpindle(false, true, getFramePosition(currentSection.getFinalPosition()));
  //  }

  if (getProperty("gotPartCatcher") && partCutoff && currentSection.partCatcher) {
    engagePartCatcher(false);
  }
  if (partCutoff) {
    writeBlock(gFormat.format(53), "X" + xFormat.format(0));
  }
  
  /*
  // Handled in start of onSection
  if (!isLastSection()) {
    if ((getLiveToolingMode(getNextSection()) < 0) && !currentSection.isPatterned() && (getLiveToolingMode(currentSection) >= 0)) {
      writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(true))));
    }
  }
*/
  
  if (((getCurrentSectionId() + 1) >= getNumberOfSections()) ||
    (tool.number != getNextSection().getTool().number)) {
    onCommand(COMMAND_BREAK_CONTROL);
  }
  
  /*
  // Handled in onSection
  if ((currentSection.getType() == TYPE_MILLING) &&
      (!hasNextSection() || (hasNextSection() && (getNextSection().getType() != TYPE_MILLING)))) {
    // exit milling mode
    if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
      // +Z
    } else if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, -1))) {
      // -Z
    } else {
      onCommand(COMMAND_STOP_SPINDLE);
    }
  }
*/

  forceXZCMode = false;
  forcePolarMode = false;
  partCutoff = false;
  forceAny();
}

function onClose() {

  var liveTool = getSpindle(false) == SPINDLE_LIVE;
  optionalSection = false;
  onCommand(COMMAND_STOP_SPINDLE);
  setCoolant(COOLANT_OFF);

  writeln("");

  gMotionModal.reset();
  if (gotSecondarySpindle) {
    writeBlock(gMotionModal.format(0), gFormat.format(53), barOutput.format(0)); // retract Sub Spindle if applicable
  }
  if (machineState.tailstockIsActive) {
    writeBlock(getCode("TAILSTOCK_OFF"));
    writeBlock(mFormat.format(32), formatComment("RETURN TAILSTOCK TO HOME POSITION"));
  }
  // Move to home position
  goHome();

  if (!getProperty("optimizeCaxisSelect")) {
    cAxisEngageModal.reset();
  }
  if (liveTool) {
    if (!stockTransferIsActive) {
      writeBlock(gFormat.format(53), "H" + abcFormat.format(0)); // unwind
      cAxisEngageModal.reset();
      writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(true))));
    }
  }

  // Automatically eject part
  if (ejectRoutine) {
    ejectPart();
  }

  writeln("");
  onImpliedCommand(COMMAND_END);
  if (getProperty("looping")) {
    //writeBlock(mFormat.format(54), formatComment(localize("Increment part counter"))); //increment part counter
    writeBlock(mFormat.format(99));
  } else {
    onCommand(COMMAND_OPEN_DOOR);
    writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
  }
  //writeln("%");
}

function setProperty(property, value) {
  properties[property].current = value;
}
// <<<<< INCLUDED FROM ../common/mazak mill-turn.cps
properties.maximumSpindleSpeed.value = 6000;
