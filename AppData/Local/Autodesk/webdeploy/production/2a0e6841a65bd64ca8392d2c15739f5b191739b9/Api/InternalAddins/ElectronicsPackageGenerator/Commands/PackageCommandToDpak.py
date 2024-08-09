import adsk.core
from . import PackageCommand
from ..Utilities import addin_utility,fusion_ui, constant
from ..Utilities.localization import _LCLZ

PIN_NUM_OPTIONS = [3, 4, 5, 6, 7, 8, 9, 10, 12, 16]

class PackageCommandToDpak(PackageCommand.PackageCommand):
    def __init__(self, name: str, options: dict):
        super().__init__(name, options)

        #overwrite some specific settings of this command. 
        self.cmd_id = 'cmd_id_TODPAK'
        self.cmd_name = _LCLZ('CmdNameToDpak', 'TO/DPAK Generator')
        self.cmd_description = _LCLZ('CmdDescToDpak', 'Generate To/Dpak Packages')
        self.cmd_ctrl_id = self.cmd_id
        self.dialog_width = 330
        self.dialog_height = 800

    def get_defalt_ui_data(self):
        #default parameters
        ui_data = {}
        ui_data['type'] = constant.PKG_TYPE_DPAK
        ui_data['cmd_id'] = self.cmd_id
        ui_data['densityLevel'] = constant.DENSITY_LEVEL_SMD['Nominal (N)']
        ui_data['padShape'] = constant.SMD_PAD_SHAPE.get('Rectangle')
        ui_data['hasTruncatedPin'] = False
        ui_data['roundedPadCornerSize'] = 40
        ui_data['horizontalPadCount'] = 4
        ui_data['verticalPinPitch'] = 0.254
        ui_data['extendedEdgeWidth'] = 0.101
        ui_data['horizontalLeadToLeadSpanMax'] = 1.067
        ui_data['horizontalLeadToLeadSpanMin'] = 1.041
        ui_data['padWidthMax'] = 0.104
        ui_data['padWidthMin'] = 0.079
        ui_data['oddPadWidthMax'] = 0.649
        ui_data['oddPadWidthMin'] = 0.649
        ui_data['padHeightMin'] = 0.063
        ui_data['padHeightMax'] = 0.079
        ui_data['oddPadHeightMax'] = 0.559
        ui_data['oddPadHeightMin'] = 0.559
        ui_data['bodyLengthMin'] = 0.827
        ui_data['bodyLengthMax'] = 0.852
        ui_data['bodyWidthMin'] = 0.689
        ui_data['bodyWidthMax'] = 0.714
        ui_data['bodyHeightMax'] = 0.24
        ui_data['silkscreenMappingTypeToBody'] = constant.SILKSCREEN_MAPPING_TO_BODY.get('MappingTypeToBodyMax')
        ui_data['fabricationTolerance'] = 0.005
        ui_data['placementTolerance'] = 0.003
        ui_data['hasCustomFootprint'] = False
        ui_data['customPadLength'] = 0.089
        ui_data['customPadWidth'] = 0.181
        ui_data['customOddPadLength'] = 0.576
        ui_data['customOddPadWidth'] = 0.702
        ui_data['customPadSpan1'] = 1.139
        return ui_data

    def validate_ui_input(self, inputs: adsk.core.CommandInputs):

        status = super().validate_ui_input(inputs)
        #input field related check
        command = inputs.itemById('extendedEdgeWidth')
        tooltip = command.tooltip
        name = command.name
        if command.value <= 0 :
            status.add_error(tooltip + ' (' + name + ') ' +_LCLZ("MaxError", "can't be equal to or less than 0."))

        return status

    def update_ui_data(self, inputs):
        # update date from UI inputs
        input_data = self.get_inputs()
        for param in self.ui_data:
            if param in input_data:
                self.ui_data[param] = input_data[param]
        
        # update the density level
        self.ui_data['densityLevel'] = list(constant.DENSITY_LEVEL_SMD.values())[inputs.itemById('densityLevel').selectedItem.index]
        self.ui_data['silkscreenMappingTypeToBody'] = list(constant.SILKSCREEN_MAPPING_TO_BODY.values())[inputs.itemById('silkscreenMappingTypeToBody').selectedItem.index]
        self.ui_data['padShape'] = list(constant.SMD_PAD_SHAPE.values())[inputs.itemById('padShape').selectedItem.index]
        # update the pin num. convert from str to int
        self.ui_data['horizontalPadCount'] = int(input_data['horizontalPadCount'])

    def on_create(self, command: adsk.core.Command, inputs: adsk.core.CommandInputs):
        
        super().on_create(command, inputs)

        ao = addin_utility.AppObjects()

        # Create a package tab input.
        tab1_cmd_inputs = inputs.addTabCommandInput('tab_1', _LCLZ('package', 'Package'))
        tab1_inputs = tab1_cmd_inputs.children
        
        # Create image input.
        labeled_image = tab1_inputs.addImageCommandInput('ToDpakImage', '', 'Resources/img/TO-DPAK-Labeled.png')
        labeled_image.isFullWidth = True
        labeled_image.isVisible = True

        pin_num = tab1_inputs.addDropDownCommandInput('horizontalPadCount', _LCLZ('#Pins', '# Pins'), adsk.core.DropDownStyles.TextListDropDownStyle)
        for n in PIN_NUM_OPTIONS:
            pin_num.listItems.add(str(n), True if n == self.ui_data['horizontalPadCount'] else False, '')
        pin_num.maxVisibleItems = len(PIN_NUM_OPTIONS)
        
        #Create truncated middle pin check option
        truncate_middle_pin = tab1_inputs.addBoolValueInput('hasTruncatedPin',  _LCLZ('truncateMiddlePin' , 'Truncate Middle Pin'), True, '', self.ui_data['hasTruncatedPin'])
        if self.ui_data['horizontalPadCount'] in (4, 6, 8):
            truncate_middle_pin.isVisible = True
        else:
            truncate_middle_pin.isVisible = False
        # Create dropdown input with test list style.
        pad_shape = tab1_inputs.addDropDownCommandInput('padShape', _LCLZ('padShape', 'Pad Shape'), adsk.core.DropDownStyles.TextListDropDownStyle)
        pad_shape_list = pad_shape.listItems
        pad_shape_list.add(_LCLZ('Rectangle', constant.SMD_PAD_SHAPE.get('Rectangle')), True if constant.SMD_PAD_SHAPE.get('Rectangle') == self.ui_data['padShape'] else False, "")        
        pad_shape_list.add(_LCLZ('RoundedRectangle', constant.SMD_PAD_SHAPE.get("RoundedRectangle")), True if constant.SMD_PAD_SHAPE.get("RoundedRectangle") == self.ui_data['padShape'] else False, "")
        pad_shape.isVisible = not self.only_3d_model_generator
        pad_shape.maxVisibleItems = 2
        # create round corner size input
        rounded_corner = tab1_inputs.addValueInput('roundedPadCornerSize', "Pad Roundness (%)", '', adsk.core.ValueInput.createByReal(self.ui_data['roundedPadCornerSize']))
        rounded_corner.isVisible = True if constant.SMD_PAD_SHAPE.get('RoundedRectangle') == self.ui_data['padShape'] else False

        # create pin pitch e
        pin_pitch = tab1_inputs.addValueInput('verticalPinPitch', 'e', ao.units_manager.defaultLengthUnits, adsk.core.ValueInput.createByReal(self.ui_data['verticalPinPitch']))
        pin_pitch.tooltip = _LCLZ('pinPitch', 'Pin Pitch')

        # create extended edge width L1
        extend_edge_length = tab1_inputs.addValueInput('extendedEdgeWidth', 'L1', ao.units_manager.defaultLengthUnits, adsk.core.ValueInput.createByReal(self.ui_data['extendedEdgeWidth']))
        extend_edge_length.tooltip = _LCLZ('extendedEdgeLength', 'Extended Edge Length')

        # table
        table = tab1_inputs.addTableCommandInput('bodyDimensionTable', 'Table', 3, '1:2:2')
        table.hasGrid = False
        table.tablePresentationStyle = 2
        table.maximumVisibleRows = 9
        fusion_ui.add_title_to_table(table, '', _LCLZ('min', 'Min'), _LCLZ('max', 'Max'))

        fusion_ui.add_row_to_table(table, 'horizontalLeadToLeadSpan', 'E', adsk.core.ValueInput.createByReal(self.ui_data['horizontalLeadToLeadSpanMin']), adsk.core.ValueInput.createByReal(self.ui_data['horizontalLeadToLeadSpanMax']), _LCLZ('leadSpan', 'Lead Span'))
        fusion_ui.add_row_to_table(table, 'padWidth', 'L', adsk.core.ValueInput.createByReal(self.ui_data['padWidthMin']), adsk.core.ValueInput.createByReal(self.ui_data['padWidthMax']), _LCLZ('terminalLength', 'Terminal Length'))
        fusion_ui.add_row_to_table(table, 'oddPadWidth', 'E2', adsk.core.ValueInput.createByReal(self.ui_data['oddPadWidthMin']), adsk.core.ValueInput.createByReal(self.ui_data['oddPadWidthMax']), _LCLZ('tabLength', 'Tab Length'))
        fusion_ui.add_row_to_table(table, 'padHeight', 'b', adsk.core.ValueInput.createByReal(self.ui_data['padHeightMin']), adsk.core.ValueInput.createByReal(self.ui_data['padHeightMax']), _LCLZ('terminalWidth', 'Terminal Width'))
        fusion_ui.add_row_to_table(table, 'oddPadHeight', 'b1', adsk.core.ValueInput.createByReal(self.ui_data['oddPadHeightMin']), adsk.core.ValueInput.createByReal(self.ui_data['oddPadHeightMax']), _LCLZ('tabWidth', 'Tab Width'))
        fusion_ui.add_row_to_table(table, 'bodyLength', 'D', adsk.core.ValueInput.createByReal(self.ui_data['bodyLengthMin']), adsk.core.ValueInput.createByReal(self.ui_data['bodyLengthMax']), _LCLZ('bodyLength', 'Body Length'))
        fusion_ui.add_row_to_table(table, 'bodyWidth', 'E1', adsk.core.ValueInput.createByReal(self.ui_data['bodyWidthMin']), adsk.core.ValueInput.createByReal(self.ui_data['bodyWidthMax']), _LCLZ('bodyWidth', 'Body Width'))
        fusion_ui.add_row_to_table(table, 'bodyHeight', 'A', None, adsk.core.ValueInput.createByReal(self.ui_data['bodyHeightMax']), _LCLZ('bodyHeight', 'Body Height'))

        # Create dropdown input with test list style.
        map_silkscreen = tab1_inputs.addDropDownCommandInput('silkscreenMappingTypeToBody', _LCLZ('mapSilkscreen', 'Map Silkscreen to Body'), adsk.core.DropDownStyles.TextListDropDownStyle)
        map_silkscreen_list = map_silkscreen.listItems
        for t in constant.SILKSCREEN_MAPPING_TO_BODY:
            map_silkscreen_list.add(_LCLZ(t, constant.SILKSCREEN_MAPPING_TO_BODY.get(t)), True if constant.SILKSCREEN_MAPPING_TO_BODY.get(t) == self.ui_data['silkscreenMappingTypeToBody'] else False, '')
        map_silkscreen.isVisible = not self.only_3d_model_generator
        map_silkscreen.maxVisibleItems = len(constant.SILKSCREEN_MAPPING_TO_BODY)

        # Create a custom footprint tab input.
        tab2_cmd_inputs = inputs.addTabCommandInput('tab_2', _LCLZ('footprint', 'Footprint'))
        custom_footprint_inputs = tab2_cmd_inputs.children
        tab2_cmd_inputs.isVisible = not self.only_3d_model_generator

        # Create image input.
        enable_custom_footprint = custom_footprint_inputs.addBoolValueInput('hasCustomFootprint', _LCLZ('hasCustomFootprint', 'Custom Footprint'), True, '', self.ui_data['hasCustomFootprint'])
        custom_footprint_image = custom_footprint_inputs.addImageCommandInput('customToDpakImage', '', 'Resources/img/ToDpak-Custom-Footprint.png')
        custom_footprint_image.isFullWidth = True
        custom_footprint_image.isVisible = True
        custom_pad_length = custom_footprint_inputs.addValueInput('customPadLength', 'l',  ao.units_manager.defaultLengthUnits, adsk.core.ValueInput.createByReal(self.ui_data['customPadLength']))
        custom_pad_length.isEnabled = True if enable_custom_footprint.value else False
        custom_pad_length.tooltip = _LCLZ("customPadLength", 'Custom Pad Length')
        custom_pad_width = custom_footprint_inputs.addValueInput('customPadWidth', 'c',  ao.units_manager.defaultLengthUnits, adsk.core.ValueInput.createByReal(self.ui_data['customPadWidth']))
        custom_pad_width.isEnabled = True if enable_custom_footprint.value else False
        custom_pad_width.tooltip = _LCLZ('customPadWidth', 'Custom Pad Width')
        custom_odd_pad_length = custom_footprint_inputs.addValueInput('customOddPadLength', 'l1',  ao.units_manager.defaultLengthUnits, adsk.core.ValueInput.createByReal(self.ui_data['customOddPadLength']))
        custom_odd_pad_length.isEnabled = True if enable_custom_footprint.value else False
        custom_odd_pad_length.tooltip = _LCLZ('customOddPadLength', 'Custom Odd Pad Length')
        custom_odd_pad_width = custom_footprint_inputs.addValueInput('customOddPadWidth', 'c1',  ao.units_manager.defaultLengthUnits, adsk.core.ValueInput.createByReal(self.ui_data['customOddPadWidth']))
        custom_odd_pad_width.isEnabled = True if enable_custom_footprint.value else False
        custom_odd_pad_width.tooltip = _LCLZ('customOddPadWidth', 'Custom Odd Pad Width')
        custom_pad_span1 = custom_footprint_inputs.addValueInput('customPadSpan1', 'z',  ao.units_manager.defaultLengthUnits, adsk.core.ValueInput.createByReal(self.ui_data['customPadSpan1']))
        custom_pad_span1.isEnabled = True if enable_custom_footprint.value else False
        custom_pad_span1.tooltip = _LCLZ('customPadSpan1', 'Custom Pad Span 1')

        #to reflect the model param e
        pin_pitch = custom_footprint_inputs.addValueInput('pinPitch', 'e',  ao.units_manager.defaultLengthUnits, adsk.core.ValueInput.createByReal(self.ui_data['verticalPinPitch']))
        pin_pitch.isEnabled = False
        pin_pitch.tooltip = _LCLZ('pinPitchNote', 'Read-only, edit in the package tab')

        #create the tab of Manufacturing settings.
        tab3_cmd_inputs = inputs.addTabCommandInput('tab_3', _LCLZ('Manufacturing', 'Manufacturing'))
        manufacturing_inputs = tab3_cmd_inputs.children
        tab3_cmd_inputs.isVisible = not self.only_3d_model_generator

        # Create dropdown input for density level
        density_level = manufacturing_inputs.addDropDownCommandInput('densityLevel', _LCLZ('densityLevel', 'Density Level'), adsk.core.DropDownStyles.TextListDropDownStyle)
        density_level_list = density_level.listItems
        for t in constant.DENSITY_LEVEL_SMD:
            density_level_list.add(_LCLZ(t, t), True if constant.DENSITY_LEVEL_SMD.get(t) == self.ui_data['densityLevel'] else False, '')
        density_level.maxVisibleItems = len(constant.DENSITY_LEVEL_SMD)

        # fabrication Tolerance 
        manufacturing_inputs.addValueInput('fabricationTolerance', _LCLZ('fabricationTolerance', 'Fabrication Tolerance'),  ao.units_manager.defaultLengthUnits, adsk.core.ValueInput.createByReal(self.ui_data['fabricationTolerance']))
        # placement Tolerance
        manufacturing_inputs.addValueInput('placementTolerance', _LCLZ('placementTolerance', 'PlacementTolerance'),  ao.units_manager.defaultLengthUnits, adsk.core.ValueInput.createByReal(self.ui_data['placementTolerance']))
        #Update when using the custom footprint mode
        if self.ui_data['hasCustomFootprint'] : 
            tab3_cmd_inputs.isVisible = False


    def on_input_changed(self, command: adsk.core.Command, inputs: adsk.core.CommandInputs, changed_input: adsk.core.CommandInput, input_values: dict ):

        if changed_input.id == 'padShape':
            pad_shape = list(constant.SMD_PAD_SHAPE.values())[inputs.itemById('padShape').selectedItem.index]
            if pad_shape == constant.SMD_PAD_SHAPE.get("RoundedRectangle"):
                inputs.itemById('roundedPadCornerSize').isVisible = True
            else:
                inputs.itemById('roundedPadCornerSize').isVisible = False

        if changed_input.id == 'hasCustomFootprint':
            inputs.itemById('customPadLength').isEnabled = changed_input.value
            inputs.itemById('customPadWidth').isEnabled = changed_input.value
            inputs.itemById('customOddPadLength').isEnabled = changed_input.value
            inputs.itemById('customOddPadWidth').isEnabled = changed_input.value
            inputs.itemById('customPadSpan1').isEnabled = changed_input.value
            inputs.itemById('tab_3').isVisible = not changed_input.value
            
        if changed_input.id == 'horizontalPadCount':
            truncate_pin = inputs.itemById('hasTruncatedPin')
            pin_count = inputs.itemById('horizontalPadCount').selectedItem.name
            if pin_count in ("4", "6", "8"):
                truncate_pin.isVisible = True
                truncate_pin.value = self.ui_data['hasTruncatedPin'] if int(pin_count) == self.ui_data['horizontalPadCount'] else False
            else:
                truncate_pin.isVisible = False
                truncate_pin.value = False

        if not self.only_3d_model_generator:
            #update e value only when footprint tab visible
            if changed_input.id == 'verticalPinPitch' :
                inputs.itemById('pinPitch').value = inputs.itemById('verticalPinPitch').value        

# register the calculator into the factory. 
PackageCommand.cmd_factory.register_command(constant.PKG_TYPE_DPAK, PackageCommandToDpak) 
