# Use of this script is subject to the Autodesk Terms of Use.
# https://www.autodesk.com/company/terms-of-use/en/general-terms

import math
from ..Utilities import addin_utility, constant
from ..FootprintGenerators import footprint
from ..Calculators import pkg_calculator, ipc_rules


# this class defines the package Calculator for the Axial Packages.
class PackageCalculatorRadial(pkg_calculator.PackageCalculator):
	
	# initialize the data members
	def __init__(self, pkg_type: str):
		super().__init__(pkg_type)
					

	def get_general_footprint(self):
		pass

	def get_3d_model_data(self):
		pass

	# process the data for 3d model generator	
	def get_ipc_3d_model_data(self):
		model_data = {}
		model_data['type'] = self.pkg_type
		model_data['A'] = self.ui_data['bodyHeightMax']
		model_data['D'] = self.ui_data['bodyWidthMax']
		model_data['b'] = self.ui_data['terminalWidthMax']
		model_data['e'] = self.ui_data['verticalPinPitch']
		
		if (self.ui_data['componentFamily'] == constant.COMP_FAMILY_POLARIZED_CAPACITOR or self.ui_data['componentFamily'] == constant.COMP_FAMILY_POLARIZED_INDUCTOR):
			model_data['isPolarized'] = 1
		else : 
			model_data['isPolarized'] = 0

        # get the proper body color
		hex_rgb = self.ui_data['bodyColor']
		model_data['color_r'] = int(hex_rgb[1:3],16)
		model_data['color_g'] = int(hex_rgb[3:5],16)
		model_data['color_b'] = int(hex_rgb[5:7],16)
        
		return model_data
		
	def get_footprint(self):
		
		footprint_data = []
		# get the pin pitch
		pin_pitch = self.ui_data['verticalPinPitch']

		if self.ui_data['hasCustomFootprint'] :
			drill_size = self.ui_data['customHoleDiameter']
			pad_diameter = self.ui_data['customPadDiameter']
		else:
			drill_size = self.get_footprint_pad_drill_size(self.ui_data['densityLevel'],self.ui_data['terminalWidthMax'])
			pad_diameter = self.get_footprint_pad_diameter(self.ui_data['densityLevel'],self.ui_data['terminalWidthMax'],self.ui_data['padToHoleRatio'])

		# initiate the left pad data 
		left_pad = footprint.FootprintPad(-pin_pitch/2, 0, pad_diameter, drill_size)
		left_pad.name = '1'
		left_pad.shape = self.ui_data['padShape']
		footprint_data.append(left_pad)

		# initiate the right pad data 
		right_pad = footprint.FootprintPad(pin_pitch/2, 0, pad_diameter, drill_size)
		right_pad.name = '2'
		right_pad.shape = self.ui_data['padShape']
		footprint_data.append(right_pad)

		#build the silkscreen 
		body_width = self.get_silkscreen_body_width(self.ui_data['silkscreenMappingTypeToBody'])

		#Calculate parameters needed to ristict silkscreen from pads if pad overlap silkscreen data.
    	#To calculate a,h and d see https://stackoverflow.com/questions/3349125/circle-circle-intersection-points
		pad_with_clearance = pad_diameter/2 + ipc_rules.SILKSCREEN_ATTRIBUTES['Clearance'] #radius of clearence circle around pad.
		d = 0.5* pin_pitch #distance between pad center and silkscreen center

		if self.ui_data['padShape'] == 'Round':
			#X-coordinate of pad & silkscreen intersection point.
			a = (math.pow(body_width/2, 2) - math.pow(pad_with_clearance,2) + math.pow(d,2))/2/d 
			#Y-coordinate of pad & silkscreen intersection point.
			h = math.sqrt(abs(math.pow(body_width/2, 2) - math.pow(a, 2)))
		else: #pad shape is square
			#X and Y coordinates if silkcreen intersect on vertical edge of pad
			a = d - pad_with_clearance
			h = math.sqrt(abs(math.pow(body_width/2,2)-math.pow(a,2)))
			#X and Y coordinates if silkcreen intersect on horizontal edge of pad
			if h >= pad_with_clearance:
				a = math.sqrt(math.pow(body_width/2,2)-math.pow(pad_with_clearance,2))
				h = pad_with_clearance

		#Detect if pad intersect silkscreen and break the silkscreen into arcs. (pitch + padWithClearance * 2) > bodyWidth > (pitch - padWithClearance * 2)
    	#For square pad additional check needed as below case if left corners of pad are touching/outside of arc and left edge of pad is inside arc.
		if (pin_pitch + pad_with_clearance*2) > body_width and (pin_pitch - pad_with_clearance*2) < body_width or self.ui_data['padShape'] == 'Square' and math.pow(d+pad_with_clearance,2) + math.pow(pad_with_clearance,2) >= math.pow(body_width/2, 2) and (d + pad_with_clearance < body_width/2): 
			
			r = body_width/2
			curve_value = (360/math.pi) * math.asin(a/r)
			#top side arc
			arc = footprint.FootprintWire(-a,h,a,h,ipc_rules.SILKSCREEN_ATTRIBUTES['StrokeWidth'])
			arc.curve = -curve_value
			footprint_data.append(arc)
			#Bottom side arc
			arc = footprint.FootprintWire(a,-h,-a,-h,ipc_rules.SILKSCREEN_ATTRIBUTES['StrokeWidth'])
			arc.curve = -curve_value
			footprint_data.append(arc)

		else: #Draw circle if pads are inside or outside of silkscreen data.
			circle_top = footprint.FootprintCircle(0, 0, ipc_rules.SILKSCREEN_ATTRIBUTES['StrokeWidth'], body_width/2)
			footprint_data.append(circle_top)

		#draw the circle on the bottom of pcb
		circle_bottom = footprint.FootprintCircle(0, 0, ipc_rules.SILKSCREEN_ATTRIBUTES['StrokeWidth'], body_width/2)
		circle_bottom.layer = 51
		footprint_data.append(circle_bottom)

		# for polarized packages. will draw the pin one marker
		angle_at_intersect = math.atan2(h, -a)
		if self.ui_data['componentFamily'] == constant.COMP_FAMILY_POLARIZED_CAPACITOR or self.ui_data['componentFamily'] == constant.COMP_FAMILY_POLARIZED_INDUCTOR :
			
			pin_marker_size = ipc_rules.SILKSCREEN_ATTRIBUTES['dotPinMarkerSize']*1.5
			pin_marker_clearance = ipc_rules.SILKSCREEN_ATTRIBUTES['PinMarkerDotClearance']
			pin_marker_x = - body_width/2 - pin_marker_clearance - ipc_rules.SILKSCREEN_ATTRIBUTES['StrokeWidth']/2
			pin_marker_angle = max(-2.35619, -angle_at_intersect) #-135 degree
			
			#Pin marker horizontal line
			h_line = footprint.FootprintWire()
			h_line.x1 = -pin_marker_x * math.cos(pin_marker_angle) - pin_marker_size / 2
			h_line.y1 = pin_marker_x * math.sin(pin_marker_angle) + pin_marker_size / 2
			h_line.x2 = -pin_marker_x * math.cos(pin_marker_angle) + pin_marker_size / 2 
			h_line.y2 = pin_marker_x * math.sin(pin_marker_angle) + pin_marker_size / 2
			h_line.width = ipc_rules.SILKSCREEN_ATTRIBUTES['StrokeWidth']
			footprint_data.append(h_line)
			#Pin marker vertical line
			v_line = footprint.FootprintWire()
			v_line.x1 = -pin_marker_x * math.cos(pin_marker_angle)
			v_line.y1 = pin_marker_x * math.sin(pin_marker_angle) + pin_marker_size
			v_line.x2 = -pin_marker_x * math.cos(pin_marker_angle)
			v_line.y2 = pin_marker_x * math.sin(pin_marker_angle)
			v_line.width = ipc_rules.SILKSCREEN_ATTRIBUTES['StrokeWidth']
			footprint_data.append(v_line)

		#build the text
		self.build_footprint_text(footprint_data)

		return footprint_data

	def get_ipc_package_name(self):
		#CAPRD + lead spacing + W lead width + D Body Diameter + H Body Height + producibility level (A, B, C)
        #E.g.,  CAPRD508W52D300H550B
		if (self.ui_data['componentFamily'] == constant.COMP_FAMILY_POLARIZED_CAPACITOR):
			family_name = 'CAPPRD'     
		if (self.ui_data['componentFamily'] == constant.COMP_FAMILY_NONPOLARIZED_CAPACITOR):
			family_name = 'CAPRD' 
		if (self.ui_data['componentFamily'] == constant.COMP_FAMILY_POLARIZED_INDUCTOR):
			family_name = 'INDPRD' 
		if (self.ui_data['componentFamily'] == constant.COMP_FAMILY_NONPOLARIZED_INDUCTOR):
			family_name = 'INDRD' 

		pkg_name = family_name 
		pkg_name += str(int((self.ui_data['verticalPinPitch']*1000))) 
		pkg_name += 'W' + str(int((self.ui_data['terminalWidthMax']*1000))) 
		pkg_name += 'D' + str(int(((self.ui_data['bodyWidthMax'] * 1000 +self.ui_data['bodyWidthMin'] * 1000 )/2)))
		pkg_name += 'H' + str(int(((self.ui_data['bodyHeightMax'])*1000))) 		
		if not self.ui_data['hasCustomFootprint'] :
			pkg_name += self.get_producibility_level_for_pth(self.ui_data['densityLevel'])	
		return pkg_name
		
	def get_ipc_package_description(self):

		if (self.ui_data['componentFamily'] == constant.COMP_FAMILY_POLARIZED_CAPACITOR):
			family_name = 'Polarized Capacitor'   
		if (self.ui_data['componentFamily'] == constant.COMP_FAMILY_NONPOLARIZED_CAPACITOR):
			family_name = 'Non-Polarized Capacitor'
		if (self.ui_data['componentFamily'] == constant.COMP_FAMILY_POLARIZED_INDUCTOR):
			family_name = 'Polarized Inductor'
		if (self.ui_data['componentFamily'] == constant.COMP_FAMILY_NONPOLARIZED_INDUCTOR):
			family_name = 'Non-Polarized Inductor'

		ao = addin_utility.AppObjects()
		unit = 'mm'
		# get the pin pitch
		pin_pitch = ao.units_manager.convert(self.ui_data['verticalPinPitch'], 'cm', unit)
		body_width = ao.units_manager.convert((self.ui_data['bodyWidthMax']+self.ui_data['bodyWidthMin'])/2, 'cm', unit)
		body_height = ao.units_manager.convert(self.ui_data['bodyHeightMax'], 'cm', unit)
		terminal_width = ao.units_manager.convert(self.ui_data['terminalWidthMax'], 'cm', unit)

		short_description = 'Radial ' + family_name + ', '
		short_description += str('{:.2f}'.format(round(pin_pitch,2))) + ' ' + unit + ' pitch, '
		short_description += str('{:.2f}'.format(round(body_width,2))) + ' ' + unit + ' body diameter, '
		short_description += str('{:.2f}'.format(round(body_height,2))) + ' ' + unit + ' body height'		    

		full_description = 'Radial ' + family_name + ' package'
		full_description += ' with ' + str('{:.2f}'.format(round(pin_pitch,2))) + ' ' + unit + ' pitch (lead spacing), '
		full_description += str('{:.2f}'.format(round(terminal_width,2))) + ' ' + unit + ' lead diameter, '
		full_description += str('{:.2f}'.format(round(body_width,2))) + ' ' + unit + ' body diameter'
		full_description += ' and '+ str('{:.2f}'.format(round(body_height,2))) + ' ' + unit + ' body height'

		return short_description + '\n <p>' + full_description + '</p>'

	def	get_ipc_package_metadata(self):
		super().get_ipc_package_metadata()
		ao = addin_utility.AppObjects()
		self.metadata['ipcFamily'] = "RADIAL"
		self.metadata["bodyWidth"] = str(round((self.ui_data['bodyWidthMax']+self.ui_data['bodyWidthMin'])/2 * 10, 4))
		self.metadata["bodyLength"] = self.metadata["bodyWidth"]
		self.metadata["pitch"] = str(round(ao.units_manager.convert(self.ui_data['verticalPinPitch'], 'cm', 'mm'), 4))
		self.metadata["pins"] = str(self.ui_data['horizontalPadCount'])
		
		return self.metadata

# register the calculator into the factory. 
pkg_calculator.calc_factory.register_calculator(constant.PKG_TYPE_RADIAL_ECAP, PackageCalculatorRadial) 
pkg_calculator.calc_factory.register_calculator(constant.PKG_TYPE_RADIAL_INDUCTOR, PackageCalculatorRadial)

