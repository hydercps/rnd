import maya.OpenMayaMPx as OpenMayaMPx
import maya.OpenMaya as OpenMaya
import maya.OpenMayaUI as OpenMayaUI
import maya.OpenMayaRender as OpenMayaRender

gl_renderer = OpenMayaRender.MHardwareRenderer.theRenderer()
gl_FT = gl_renderer.glFunctionTable()
commandName = 'point'

class Point(OpenMayaMPx.MPxLocatorNode):
    kPluginNodeId = OpenMaya.MTypeId(0x90000002)
    input_size = OpenMaya.MObject()
    input_red = OpenMaya.MObject()
    input_blue = OpenMaya.MObject()
    input_green = OpenMaya.MObject()
    input_box = OpenMaya.MObject()
    input_cross = OpenMaya.MObject()
    input_tick = OpenMaya.MObject()
    input_axis = OpenMaya.MObject()
    
    def __init__(self):
        OpenMayaMPx.MPxLocatorNode.__init__(self)
        self._size = 1.0
    
    def draw(self, view, mdag_path, display_style, display_status):
        size_value = OpenMaya.MPlug(self.thisMObject(), Point.input_size).asFloat()
        #r = OpenMaya.MPlug(self.thisMObject(), Point.input_red).asFloat()
        #g = OpenMaya.MPlug(self.thisMObject(), Point.input_green).asFloat()
        #b = OpenMaya.MPlug(self.thisMObject(), Point.input_blue).asFloat()
        use_box = OpenMaya.MPlug(self.thisMObject(), Point.input_box).asInt()
        use_cross = OpenMaya.MPlug(self.thisMObject(), Point.input_cross).asInt()
        use_tick = OpenMaya.MPlug(self.thisMObject(), Point.input_tick).asInt()
        use_axis = OpenMaya.MPlug(self.thisMObject(), Point.input_axis).asInt()
        
        #print display_status # 8=selected
        
        if display_status == OpenMayaUI.M3dView.kActive:
            color = OpenMaya.MColor(1.0, 1.0, 1.0)
        elif display_status == OpenMayaUI.M3dView.kLead:
            color = OpenMaya.MColor(0.26, 1.0, 0.64)
        else:
            color = OpenMaya.MColor(1.0, 1.0, 0)
        
        # Standard Maya operation colors
        #object_color = self.colorRGB(display_status)
        #r = object_color.r
        #g = object_color.g
        #b = object_color.b
        #print "%s, %s, %s" % (r, g, b)
        
        view.beginGL()
        
        gl_FT.glPushAttrib(OpenMayaRender.MGL_CURRENT_BIT)
        gl_FT.glPushAttrib(OpenMayaRender.MGL_ALL_ATTRIB_BITS)
        gl_FT.glEnable(OpenMayaRender.MGL_BLEND)
        #gl_FT.glDisable(OpenMayaRender.MGL_LIGHTING)
        gl_FT.glBegin(OpenMayaRender.MGL_LINES)
        
        if use_box == 1:
            gl_FT.glColor3f(color.r, color.g, color.b)
            val = 1*size_value
            
            # top
            gl_FT.glVertex3f(-val, val, -val)
            gl_FT.glVertex3f(val, val, -val)
            
            gl_FT.glVertex3f(val, val, -val)
            gl_FT.glVertex3f(val, val, val)
            
            gl_FT.glVertex3f(val, val, val)
            gl_FT.glVertex3f(-val, val, val)
            
            gl_FT.glVertex3f(-val, val, val)
            gl_FT.glVertex3f(-val, val, -val)
            
            # bottom
            gl_FT.glVertex3f(-val, -val, -val)
            gl_FT.glVertex3f(val, -val, -val)
            
            gl_FT.glVertex3f(val, -val, -val)
            gl_FT.glVertex3f(val, -val, val)
            
            gl_FT.glVertex3f(val, -val, val)
            gl_FT.glVertex3f(-val, -val, val)
            
            gl_FT.glVertex3f(-val, -val, val)
            gl_FT.glVertex3f(-val, -val, -val)
            
            # left
            gl_FT.glVertex3f(-val, -val, -val)
            gl_FT.glVertex3f(-val, val, -val)
            
            gl_FT.glVertex3f(-val, val, -val)
            gl_FT.glVertex3f(-val, val, val)
            
            gl_FT.glVertex3f(-val, val, val)
            gl_FT.glVertex3f(-val, -val, val)
            
            gl_FT.glVertex3f(-val, -val, val)
            gl_FT.glVertex3f(-val, -val, -val)
            
            # right
            gl_FT.glVertex3f(val, -val, -val)
            gl_FT.glVertex3f(val, val, -val)
            
            gl_FT.glVertex3f(val, val, -val)
            gl_FT.glVertex3f(val, val, val)
            
            gl_FT.glVertex3f(val, val, val)
            gl_FT.glVertex3f(val, -val, val)
            
            gl_FT.glVertex3f(val, -val, val)
            gl_FT.glVertex3f(val, -val, -val)
        
        if use_cross == 1:
            gl_FT.glColor3f(color.r, color.g, color.b)
            val = 1*size_value
            
            gl_FT.glVertex3f(0, -val, 0)
            gl_FT.glVertex3f(0, val, 0)
            
            gl_FT.glVertex3f(-val, 0, 0)
            gl_FT.glVertex3f(val, 0, 0)
            
            gl_FT.glVertex3f(0, 0, -val)
            gl_FT.glVertex3f(0, 0, val)
        
        if use_tick == 1:
            gl_FT.glColor3f(color.r, color.g, color.b)
            val = 0.1*size_value
            
            gl_FT.glVertex3f(-val, val, 0)
            gl_FT.glVertex3f(val, -val, 0)
            
            gl_FT.glVertex3f(val, val, 0)
            gl_FT.glVertex3f(-val, -val, 0)
            
            gl_FT.glVertex3f(0, val, -val)
            gl_FT.glVertex3f(0, -val, val)
            
            gl_FT.glVertex3f(0, val, val)
            gl_FT.glVertex3f(0, -val, -val)
            
            gl_FT.glVertex3f(val, 0, -val)
            gl_FT.glVertex3f(-val, 0, val)
            
            gl_FT.glVertex3f(val, 0, val)
            gl_FT.glVertex3f(-val, 0, -val)
        
        if use_axis == 1:
            val = 0.1*size_value
            
            gl_FT.glColor3f(1, 0, 0)
            gl_FT.glVertex3f(0, 0, 0)
            gl_FT.glVertex3f(1, 0, 0)
            
            gl_FT.glColor3f(0, 1, 0)
            gl_FT.glVertex3f(0, 0, 0)
            gl_FT.glVertex3f(0, 1, 0)
            
            gl_FT.glColor3f(0, 0, 1)
            gl_FT.glVertex3f(0, 0, 0)
            gl_FT.glVertex3f(0, 0, 1)
            
        gl_FT.glEnd()
        gl_FT.glDisable(OpenMayaRender.MGL_BLEND)
        gl_FT.glPopAttrib()
        gl_FT.glPopAttrib()
        #gl_FT.glEnable(OpenMayaRender.MGL_LIGHTING)
        
        view.endGL()

def nodeCreator():
    return OpenMayaMPx.asMPxPtr( Point() )

def nodeInitializer():
    nAttr = OpenMaya.MFnNumericAttribute()

    Point.input_size = nAttr.create('size', 'size', OpenMaya.MFnNumericData.kFloat, 1.0)
    nAttr.setKeyable(True)
    Point.addAttribute(Point.input_size)
    
    Point.input_box = nAttr.create('box', 'box', OpenMaya.MFnNumericData.kInt, 0)
    nAttr.setKeyable(True)
    nAttr.setMin(0)
    nAttr.setMax(1)
    Point.addAttribute(Point.input_box)
    
    Point.input_cross = nAttr.create('cross', 'cross', OpenMaya.MFnNumericData.kInt, 1)
    nAttr.setKeyable(True)
    nAttr.setMin(0)
    nAttr.setMax(1)
    Point.addAttribute(Point.input_cross)
    
    Point.input_tick = nAttr.create('tick', 'tick', OpenMaya.MFnNumericData.kInt, 0)
    nAttr.setKeyable(True)
    nAttr.setMin(0)
    nAttr.setMax(1)
    Point.addAttribute(Point.input_tick)
    
    Point.input_axis = nAttr.create('axis', 'axis', OpenMaya.MFnNumericData.kInt, 0)
    nAttr.setKeyable(True)
    nAttr.setMin(0)
    nAttr.setMax(1)
    Point.addAttribute(Point.input_axis)
    
    Point.input_red = nAttr.create('red', 'red', OpenMaya.MFnNumericData.kFloat, 1.0)
    nAttr.setKeyable(True)
    nAttr.setMin(0)
    nAttr.setMax(1.0)
    Point.addAttribute(Point.input_red)
    
    Point.input_green = nAttr.create('green', 'green', OpenMaya.MFnNumericData.kFloat, 1.0)
    nAttr.setKeyable(True)
    nAttr.setMin(0)
    nAttr.setMax(1.0)
    Point.addAttribute(Point.input_green)
    
    Point.input_blue = nAttr.create('blue', 'blue', OpenMaya.MFnNumericData.kFloat, 1.0)
    nAttr.setKeyable(True)
    nAttr.setMin(0)
    nAttr.setMax(1.0)
    Point.addAttribute(Point.input_blue)
    
def initializePlugin(obj):
    plugin = OpenMayaMPx.MFnPlugin(obj, 'Jason Labbe', '1.0', 'Any')
    try:
        print 'Loading point node'
        plugin.registerNode(commandName, 
                            Point.kPluginNodeId, 
                            nodeCreator, 
                            nodeInitializer,
                            OpenMayaMPx.MPxNode.kLocatorNode)
    except:
        raise RuntimeError, 'Failed to register node: {0}'.format(commandName)

def uninitializePlugin(obj):
    plugin = OpenMayaMPx.MFnPlugin(obj)
    try:
        plugin.deregisterNode(Point.kPluginNodeId)
    except:
        raise RuntimeError, 'Failed to register node: {0}'.format(commandName)
