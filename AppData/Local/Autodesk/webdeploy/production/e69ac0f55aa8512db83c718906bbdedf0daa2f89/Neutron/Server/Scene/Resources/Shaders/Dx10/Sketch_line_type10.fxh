#ifndef _HQ_FX_LT_COMMON__
#define _HQ_FX_LT_COMMON__

#include "Sketch_math10.fxh"
#include "Sketch_primitive10.fxh"

// line pattern textures
static const float LINE_PATTERN_DOT_DIST = 0.5f;//1.0f;

// line pattern mask uses 16-bits 
static const unsigned int LINE_PATTERN_MASK = 0xff;
// 15 bits used to save line-pattern id
static const unsigned int PATTERN_ID_MASK = 0x1ff;
// 1 bit used to save if this pattern is a pure dot pattern
static const unsigned int PURE_DOT_MASK = 0x200;

// the line pattern texture row width
static const unsigned int PATTERN_TEX_WIDTH = 256;

// line pattern property texture
Texture2D<float4> gPatternPropTex : LinePatternPropTexture;
// line pattern texture
Texture2D<float2> gPatternTex : LinePatternTexture;

float4 load_line_pattern_prop(int2 offset)
{
    return gPatternPropTex.Load(int3(offset, 0));
}

float2 load_pattern_val(uint pattern_index, uint pattern_offset)
{
    return gPatternTex.Load(int3(pattern_offset, pattern_index, 0));
}

// hatch line pattern property texture
Texture2D<float4> gHatchPatternPropTex : HatchLinePatternPropTexture;
// hatch line pattern texture
Texture2D<float2> gHatchPatternTex : HatchLinePatternTexture;

float4 load_hatch_line_pattern_prop(int2 offset)
{
    return gHatchPatternPropTex.Load(int3(offset, 0));
}
float2 load_hatch_pattern_val(uint pattern_index, uint pattern_offset)
{
    return gHatchPatternTex.Load(int3(pattern_offset, pattern_index, 0));
}

// check if is pline-gen enabled if input is negative zero.
bool is_pline_gen(float skip_len)
{
    uint skip_len_bits = asuint(skip_len);

    return skip_len_bits == 0x80000000;
}

// check line type pattern texture for single line.
struct SimpleLineTypeAttr
{
    float toLineDist; // dist to the line
    float startDist; // dist to start point
    float endDist; // dist to end point
    float startSkipLen;
    float endSkipLen;
    float2 lineDir; // line direction
    float patternScale;
    float patternOffset;
    uint patternID;
    bool isClosed;
    bool isCurve;
};
struct SimpleLineTypeResult
{
    bool  isDot;
    float dotDist;
    bool  noDotAA;
    bool  isOut;
    float outAlpha;
};

bool is_first_segment(float scale)
{
    return (asuint(scale) & 0x80000000) != 0;
}
float get_real_pattern_scale(float scale)
{
    return abs(scale);
}

bool is_pure_dot_pattern(uint index)
{
    return  (index&PURE_DOT_MASK) != 0;
}
uint get_real_pattern_index(uint index)
{
    return  (index&PATTERN_ID_MASK);
}

uint get_real_tex_offset(uint tex_offset)
{
    return (tex_offset&LINE_PATTERN_MASK);
}
uint get_real_tex_offset_left(uint tex_offset)
{
    return ((tex_offset-1)&LINE_PATTERN_MASK);
}
uint get_real_tex_offset_right(uint tex_offset)
{
    return ((tex_offset + 1)&LINE_PATTERN_MASK);
}

bool is_continue_pattern(float scale)
{
    return scale == 0.0f;
}

float get_dot_size(float width)
{
    return width * 0.5f + 1.0f;
}

float get_pattern_screen_len(float scale)
{
    return PATTERN_TEX_WIDTH / scale;
}

float is_pattern_too_short(float scale)
{
    float pattern_scr_len = get_pattern_screen_len(scale);
    if (pattern_scr_len < 2.0f)
        return  true;

    return false;
}
bool in_skip_len(float dist, float skip_len)
{
    return dist <= skip_len;
}

bool in_dash_skip_len(float start_dist, float start_skip_len,
    float end_dist, float end_skip_len)
{

    [branch]if (gNoAAMode != 0)
    {
        if (start_dist < 0 || end_dist < 0)
            return false;
    }

    if ((in_skip_len(start_dist, start_skip_len)) ||
        (in_skip_len(end_dist, end_skip_len)))
        return true;

    return false;
}
bool valid_skip_len(float skip_len)
{
    return skip_len != 0.0f;
}

bool in_wide_dash_skip_len(float start_dist, float start_skip_len,
    float end_dist, float end_skip_len)
{
    // if pline gen on, only first/last segment has start/end skip len.
    // if pline gen off, ignore the start/end point when start/end skip
    //   len exactly equal to zero.
    if ((valid_skip_len(start_skip_len)) &&
        in_skip_len(start_dist, start_skip_len))
    {
         return true;
    }
    if ((valid_skip_len(end_skip_len)) &&
        in_skip_len(end_dist, end_skip_len))
    {
        return true;
    }

    return false;
}

float dot_skip_len_safe_range(float skip_len)
{
    return skip_len + LINE_PATTERN_DOT_DIST*2.0f + 0.25f;
}
float dot_end_len_safe_range(float test_dist)
{
    return LINE_PATTERN_DOT_DIST*2.0f + test_dist*2.0f - 1.0f;
}

bool in_dot_skip_len(float dist, float skip_len)
{
    return dist <= dot_skip_len_safe_range(skip_len);
}

float noaa_test_dist(bool isCurve)
{
    return isCurve ? 1.0f : 0.5f;
}

bool is_close_to_end_point_dot(float dist, float test_dist, float to_line_dist, float2 line_dir)
{
    [branch]if (gNoAAMode != 0)
    {
        float2 dot_to_pixel = dist * line_dir + to_line_dist * float2(line_dir.y, -line_dir.x);
        return abs(abs(line_dir.x) > abs(line_dir.y) ? dot_to_pixel.x : dot_to_pixel.y) <= test_dist;
    }
    else
        return dist < dot_end_len_safe_range(test_dist);
}
bool is_clost_to_cloased_end_point_dot(float dist)
{
    [branch]if (gNoAAMode != 0)
        return false;
    else
        return dist < LINE_PATTERN_DOT_DIST*2.0f;
}

float get_distance_to_end_point(float dist, float test_dist, bool isClosed)
{
    return isClosed ? abs(dist) : abs(dist - test_dist + 1.0f);
}

bool is_inside_dot_range(float dist, float test_dist, float to_line_dist, float2 line_dir, bool isCurve)
{
    [branch]if (gNoAAMode != 0)
    {
        float2 dot_to_pixel = dist * line_dir + to_line_dist * float2(line_dir.y, -line_dir.x);
        return abs(abs(line_dir.x) > abs(line_dir.y) ? dot_to_pixel.x : dot_to_pixel.y) <= noaa_test_dist(isCurve);
    }
    else
    {
        return (dist >= -LINE_PATTERN_DOT_DIST - test_dist) &&
            (dist < LINE_PATTERN_DOT_DIST + test_dist);
    }
}

bool is_dash_too_short(float accum_len, float pattern_scale, float width)
{
    // compute screen length of a single pattern.
    float accum_scr_len = (accum_len - 2.0f) / pattern_scale;

    // if a single pattern is too short, return continues.
    if (accum_scr_len < width*0.5f)
    {
        return true;
    }

    return false;

}

bool segment_is_dash(float dist)
{
    return dist < 0.0f;
}

bool in_left_dash(float dist, float tex_bias)
{
    return 1.0 - tex_bias >= abs(dist);
}
bool in_right_dash(float dist, float tex_bias)
{
    return tex_bias >= abs(dist);
}
bool is_pixel_on_dash(float accum_len)
{
    return accum_len == 0.0f;
}
bool is_pixel_on_dot(float accum_len)
{
    return accum_len <= 1.0f;
}

float dist_to_dot(float tex_bias, float2 pattern_val, float pattern_scale)
{
    return (tex_bias - pattern_val.y) / pattern_scale;
}
float dist_to_left(float tex_bias, float2 pattern_val, float pattern_scale)
{
    return (abs(pattern_val.x) - 1.0f + tex_bias) / pattern_scale;
}
float dist_to_right(float tex_bias, float2 pattern_val, float pattern_scale)
{
    return (abs(pattern_val.y) - tex_bias) / pattern_scale;
}
float dist_to_left_outside(float tex_bias, float2 pattern_val, float pattern_scale)
{
    return (tex_bias + abs(pattern_val.x)) / pattern_scale;
}
float dist_to_right_outside(float tex_bias, float2 pattern_val, float pattern_scale)
{
    return (1.0f - tex_bias + abs(pattern_val.y)) / pattern_scale;;
}

void initSimpleLTResult(inout SimpleLineTypeResult output)
{
    output.isDot = false;
    output.dotDist = 0.0f;
    [branch]if (gNoAAMode != 0)
        output.noDotAA = true;
    else
        output.noDotAA = false;
    output.isOut = false;
    output.outAlpha = 0.0f;
}

struct HatchLTData
{
    float distToStart;
    float distToEnd;
    float distToPoint;
    float2 curPoint;
    float2 startPoint;
    float2 endPoint;
};

bool is_inside_noAA_hatch_dot_range(float dist, float to_line_dist, float2 line_dir, float2 curPoint)
{
    float2 dot_to_pixel = dist * line_dir + to_line_dist * float2(line_dir.y, -line_dir.x);
    float2 dotPos = curPoint - dot_to_pixel;
    if (dotPos.x - 0.5 - 0.000001 < curPoint.x && curPoint.x < dotPos.x + 0.5 - 0.000001
        && dotPos.y - 0.5 - 0.000001 < curPoint.y && curPoint.y < dotPos.y + 0.5 - 0.000001)
    {
        return true;
    }
    return false;
}

bool handle_pixel_on_dot(float tex_bias, float2 pattern_val, float to_line_dist, float2 line_dir, float pattern_scale, bool isCurve, bool isHatch, HatchLTData data, inout SimpleLineTypeResult output)
{
    [branch]if (gNoAAMode != 0)
        isHatch = false;

    // compute the distance to dot center
    float test_dist = output.noDotAA ? 0.0f : 1.0f;
    float dist = dist_to_dot(tex_bias, pattern_val, pattern_scale);

    if (isHatch && output.noDotAA && dist < 1)
    {
        output.isDot = true;
        return is_inside_noAA_hatch_dot_range(dist, to_line_dist, line_dir, data.curPoint);
    }
    // inside dot range, draw a dot. 
    else if (is_inside_dot_range(dist, test_dist, to_line_dist, line_dir, isCurve))
    {
        output.isDot = true;
        output.dotDist = -dist;
        return true;
    }
    // out side dot range, draw space.
    else
    {
        return false;
    }
}

float gauss_function(float x, float mu, float sigma)
{
    float adjust_theta = 1 / (sigma * 2.506628);
    float res = adjust_theta * exp(-1 * (x - mu)*(x - mu) / (2 * sigma*sigma));
    return min(res, 1.0f);
}

float2 getHatchPatternValue(uint pattern_index, float pattern_offset, float start_dist, float start_skip_len, float pattern_scale, out float tex_bias)
{
    // compute texture coordinate of pattern texture.
    float pattern_pos = (start_dist - start_skip_len) * pattern_scale + pattern_offset;
    uint tex_offset = uint(pattern_pos);
    tex_bias = pattern_pos - tex_offset;

    // repeat the pattern when there are one more pattern on a line.
    tex_offset = get_real_tex_offset(tex_offset);

    // sample pattern value.
    return load_hatch_pattern_val(pattern_index, tex_offset);
}

bool samplePatternValue(uint pattern_index, float pattern_offset, float to_line_dist, float start_dist, float2 line_dir, float start_skip_len, float pattern_scale, 
    bool is_pure_dot, bool isCurve, bool isHatch, HatchLTData data, inout SimpleLineTypeResult output)
{
    // compute texture coordinate of pattern texture.
    float pattern_pos = (start_dist - start_skip_len) * pattern_scale + pattern_offset;
    uint tex_offset = uint(pattern_pos);
    float tex_bias = pattern_pos - tex_offset;

    // repeat the pattern when there are one more pattern on a line.
    tex_offset = get_real_tex_offset(tex_offset);

    // sample pattern value.
    float2 pattern_val = isHatch 
        ? load_hatch_pattern_val(pattern_index, tex_offset) 
        : load_pattern_val(pattern_index, tex_offset);

    // accum_len = 0.0 means it's dash.
    float accum_len = abs(pattern_val.x) + abs(pattern_val.y);
    if (is_pixel_on_dash(accum_len))
        return true;

    // accum_len < 1.0f means dot
    if (is_pixel_on_dot(accum_len))
        return handle_pixel_on_dot(tex_bias, pattern_val, to_line_dist, line_dir, pattern_scale, isCurve, isHatch, data, output);

    // if a single pattern is too short, return continues.
    if (is_dash_too_short(accum_len, pattern_scale, 1.0f))
        return true;

    // compute the dot size.
    float dot_dist = get_dot_size(1.0);

    // if left segment is a dash.
    if (segment_is_dash(pattern_val.x))
    {
        // if current pixel inside dash, draw as dash.
        if (in_left_dash(pattern_val.x, tex_bias))
        {
            return true;
        }
        // if current pixel outside dash
        else if (!is_pure_dot && isHatch)
        {
            float left_dist = dist_to_left(tex_bias, pattern_val, pattern_scale);
            if (left_dist < dot_dist && left_dist < data.distToStart) {
                // sample previous pixel
                float pre_tex_bias;
                float2 pre_pattern_val = getHatchPatternValue(pattern_index, pattern_offset, start_dist - 1, start_skip_len, pattern_scale, pre_tex_bias);

                // if previous pixel's right segment is a dash and the pixel is out of the dash
                // this means the dash is smaller than one pixel
                if (segment_is_dash(pre_pattern_val.y) && !in_right_dash(pre_pattern_val.y, pre_tex_bias))
                {
                    float pre_right_dist = dist_to_right(pre_tex_bias, pre_pattern_val, pattern_scale);
                    if (left_dist < 0.5 && left_dist < pre_right_dist)
                        return true;
                }
                else
                {
                    [branch]if (!gNoAAMode != 0)
                    {
                        output.isOut = true;
                        output.outAlpha = gauss_function(left_dist, 0, 0.15);
                        return true;
                    }
                }
            }
        }
    }
    // if left segment is a dot.
    else
    {
        // compute distance to dot center.
        float test_dist = output.noDotAA ? 0.0f : 1.0f;
        float dist = dist_to_left(tex_bias, pattern_val, pattern_scale);

        if (isHatch && output.noDotAA && dist < 1)
        {
            output.isDot = true;
            [branch]if (gNoAAMode != 0)
            {
                if (is_inside_dot_range(dist, test_dist, to_line_dist, line_dir, isCurve))
                    return true;
            }
            else
            {
                if (is_inside_noAA_hatch_dot_range(dist, to_line_dist, line_dir, data.curPoint))
                    return true;
            }
        }
        // if inside dot range, draw as dot.
        else if (is_inside_dot_range(dist, test_dist, to_line_dist, line_dir, isCurve))
        {
            output.isDot = true;
            output.dotDist = dist;

            return true;
        }

    }


    // if right segment is a dash.
    if (segment_is_dash(pattern_val.y))
    {
        // if current pixel inside dash, draw as dash.
        if (in_right_dash(pattern_val.y, tex_bias))
        {
            return true;
        }
        // if current pixel outside dash
        else if (!is_pure_dot && isHatch)
        {
            float right_dist = dist_to_right(tex_bias, pattern_val, pattern_scale);
            if (right_dist < dot_dist && right_dist < data.distToEnd) {
                // sample previous pixel
                float next_tex_bias;
                float2 next_pattern_val = getHatchPatternValue(pattern_index, pattern_offset, start_dist + 1, start_skip_len, pattern_scale, next_tex_bias);

                // if previous pixel's right segment is a dash and the pixel is out of the dash
                // this means the dash is smaller than one pixel
                if (segment_is_dash(next_pattern_val.x) && !in_left_dash(next_pattern_val.x, next_tex_bias))
                {
                    float next_left_dist = dist_to_left(next_tex_bias, next_pattern_val, pattern_scale);
                    if (right_dist < 0.5 && right_dist < next_left_dist)
                        return true;
                }
                else
                {
                    [branch]if (!gNoAAMode != 0)
                    {
                        output.isOut = true;
                        output.outAlpha = gauss_function(right_dist, 0, 0.15);
                        return true;
                    }
                }
            }
        }
    }
    else
    {
        // compute distance to dot.
        float test_dist = output.noDotAA ? 0.0f : 1.0f;
        float dist = dist_to_right(tex_bias, pattern_val, pattern_scale);
        if (isHatch && dist > data.distToEnd)
            return false;

        if (isHatch && output.noDotAA && dist < 1)
        {
            output.isDot = true;

            [branch]if (gNoAAMode != 0)
                return is_inside_dot_range(-dist, test_dist, to_line_dist, line_dir, isCurve);
            else
                return is_inside_noAA_hatch_dot_range(-dist, to_line_dist, line_dir, data.curPoint);
        }
        // if inside dot range, draw as dot.
        else if (is_inside_dot_range(-dist, test_dist, to_line_dist, line_dir, isCurve))
        {
            output.isDot = true;
            output.dotDist = -dist;
            return true;
        }
    }

    return false;
}

bool check_line_pattern(SimpleLineTypeAttr attr, out SimpleLineTypeResult output)
{
    // assign input properties
    float to_line_dist = attr.toLineDist;
    float start_dist = attr.startDist;
    float end_dist = attr.endDist;
    float start_skip_len = attr.startSkipLen;
    float end_skip_len = attr.endSkipLen;
    float2 line_dir = attr.lineDir;
    float pattern_scale = attr.patternScale;
    float pattern_offset = attr.patternOffset;
    uint pattern_index = attr.patternID;
    bool isClosed = attr.isClosed;

    // initialize output
    initSimpleLTResult(output);

    // get first segment flag.
    bool is_first_seg = is_first_segment(pattern_scale);

    // get scale value - ignore sign bit since it's used as first segment flag.
    pattern_scale = get_real_pattern_scale(pattern_scale);

    // get pure dot flag.
    bool is_pure_dot = is_pure_dot_pattern(pattern_index);

    // get pattern index from low 31 bits. 
    pattern_index = get_real_pattern_index(pattern_index);

    // scale is zero means continue linetype.
    if (is_continue_pattern(pattern_scale))
        return true;


    if (is_pure_dot)
    {
        // do not apply dot aa effect when dot too close.
        float test_dist;
        [branch]if (gNoAAMode != 0)
        {
            output.noDotAA = true;
            test_dist = noaa_test_dist(attr.isCurve);
        }
        else
        {
        if (is_pattern_too_short(pattern_scale))
        {
            output.noDotAA = true;
            test_dist = 0.0f;
        }
        else
        {
            output.noDotAA = false;
            test_dist = 2.0f;
        }
        }

        // when dot inside start skip len.
        if (in_dot_skip_len(start_dist, start_skip_len))
        {
            // when dot close to start point.
            if (is_close_to_end_point_dot(start_dist, test_dist, to_line_dist, line_dir))
            {
                // ignore the start dot when pline-gen on.
                // when pline-gen off, only draw start dot for the first segemnt.
                if (is_pline_gen(start_skip_len) || (!is_first_seg))
                {
                    return false;
                }

                // return distance to start point.
                output.isDot = true;

                // Bug 101448: Two dots at the quadrant of the circle.
                // When draw circle with pure dot, if we have one pixel shift using "abs(start_dist - test_dist + 1.0f)", 
                // we will see two dots at the 0 degree position.
                output.dotDist = get_distance_to_end_point(start_dist, test_dist, isClosed);

                return true;
            }
            // Bug 105557:TF: GPU Linetype - Zoom pure dot linetype circle to very small will have a gap at 0 degree
            // In this bug, start_dist = 0.15, LINE_PATTERN_DOT_DIST = 0.5 and test_dist = 0, this point
            // will be discard.Then you will see gap in the 0 degree. So add this "else if" to handle this case.
            else if (isClosed && is_clost_to_cloased_end_point_dot(start_dist))
            {
                output.isDot = true;
                output.dotDist = abs(start_dist);

                return true;
            }
            // other wise ignore the dot.
            else
            {
                return false;
            }

        }

        // when dot inside end skip len.
        if (in_dot_skip_len(end_dist, end_skip_len))
        {
            // when close to end point.
            if (is_close_to_end_point_dot(end_dist, test_dist, to_line_dist, line_dir))
            {
                // ignore the end dot when pline-gen on.
                if (is_pline_gen(end_skip_len))
                {
                    return false;
                }

                // return distance to end point.
                output.isDot = true;
                output.dotDist = get_distance_to_end_point(end_dist, test_dist, isClosed);

                return true;
            }
            // Bug 105557:TF: GPU Linetype - Zoom pure dot linetype circle to very small will have a gap at 0 degree
            // In this bug, end_dist = 0.15, LINE_PATTERN_DOT_DIST = 0.5 and test_dist = 0, this point
            // will be discard.Then you will see gap in the 0 degree. So add this "else if" to handle this case.
            else if (isClosed && is_clost_to_cloased_end_point_dot(end_dist))
            {
                output.isDot = true;
                output.dotDist = abs(end_dist);

                return true;
            }
            // other wise ignore the dot.
            else
            {
                return false;
            }

        }

    }
    else if (in_dash_skip_len(start_dist, start_skip_len,end_dist, end_skip_len))
    {
        return true;            
    }

    HatchLTData data;
    data.distToStart = data.distToEnd = data.distToPoint = 0;
    data.curPoint = data.startPoint = data.endPoint = float2(0, 0);
    return samplePatternValue(pattern_index, pattern_offset, to_line_dist, start_dist, line_dir, start_skip_len, pattern_scale, is_pure_dot, attr.isCurve, false, data, output);
}
        
bool check_in_hatch_boundary(float2 startPt, float2 endPt, float2 curPt)
{
    if (abs(startPt.x - endPt.x) > 0.5
        && (curPt.x > max(startPt.x, endPt.x) || curPt.x < min(startPt.x, endPt.x)))
            return false;

    if (abs(startPt.y - endPt.y) > 0.5
        && (curPt.y > max(startPt.y, endPt.y) || curPt.y < min(startPt.y, endPt.y)))
        return false;
        
    return true;
}

bool check_hatch_line_pattern(SimpleLineTypeAttr attr, HatchLTData data, out SimpleLineTypeResult output)
{
    // initialize output
    initSimpleLTResult(output);
            
    // get scale value - ignore sign bit since it's used as first segment flag.
    float pattern_scale = get_real_pattern_scale(attr.patternScale);

    // get pure dot flag.
    uint pattern_index = attr.patternID;
    bool is_pure_dot = is_pure_dot_pattern(pattern_index);

    // get pattern index from low 31 bits. 
    pattern_index = get_real_pattern_index(pattern_index);

    // scale is zero means continue linetype.
    if (is_continue_pattern(pattern_scale))
            return true;
            
    if (is_pure_dot)
    {
        // check if in hatch boundary
        if (!check_in_hatch_boundary(data.startPoint, data.endPoint, data.curPoint))
            return false;

            output.isDot = true;
        output.noDotAA = true;
    }

    return samplePatternValue(pattern_index, attr.patternOffset, attr.toLineDist, attr.startDist, attr.lineDir, attr.startSkipLen, pattern_scale, is_pure_dot, false, true, data, output);
}



// wide line pattern attributes.
struct WideLinePatternAttr
{
    float dist;
    float width;
    float startDist;
    float endDist;
    float startSkipLen;
    float endSkipLen;
    float patternScale;
    float patternOffset;
    uint  patternIndex;
};

struct WideLineInfo
{
    float2 startPos;
    float2 endPos;
    float2 lineDir;
    bool  hasPrevLine;
    bool  hasPostLine;
};
   
struct WideLinePatternResult
{
    float dist; // distance to segment end.
    bool  is_caps; // is in caps region.
    float2 caps_center; // the center of caps.
    float2 caps_dir; // the direction of caps.

};

// initialize wide line pattern.
void init_wide_line_pattern_attr(out WideLinePatternResult attr)
{
    attr.dist = -1.0f;
    attr.is_caps = false;
    attr.caps_center = float2(0.0f, 0.0f);
    attr.caps_dir = float2(0.0f, 0.0f);
}


static const int PURE_DASH = 1; // is completely inside a dash.
static const int PURE_SPACE = -1; // is completely inside a space.
static const int MIXED = 0; // in dash/caps/dot mixed region.

void get_dist_to_left_space(float tex_bias, float2 pattern_val, float pattern_scale,
    out bool is_left_dash, out float left_dist)
{
    is_left_dash = segment_is_dash(pattern_val.x);
    left_dist = dist_to_left(tex_bias, pattern_val, pattern_scale);
}
void get_dist_to_right_space(float tex_bias, float2 pattern_val, float pattern_scale,
    out bool is_right_dash, out float right_dist)
{
    is_right_dash = segment_is_dash(pattern_val.y);
    right_dist = dist_to_right(tex_bias, pattern_val, pattern_scale);
}

void get_dist_to_left_right_space(float tex_bias, float2 pattern_val,  float pattern_scale,
    out bool is_left_dash, out float left_dist, out bool is_right_dash, out float right_dist)
{
    get_dist_to_left_space(tex_bias, pattern_val, pattern_scale,
        is_left_dash, left_dist);
    get_dist_to_right_space(tex_bias, pattern_val, pattern_scale,
        is_right_dash, right_dist);
}

void get_dist_to_left_dot(float tex_bias, uint tex_offset, uint pattern_index, float2 pattern_val, float pattern_scale,
    float dist, out bool is_left_dash, out float left_dist)
{
    // if dot on the right.
    if (dist < 0.0f)
    {
        // check if left segment is dash or dot.
        tex_offset = get_real_tex_offset_left(tex_offset);
        float2 left_pattern_val = load_pattern_val(pattern_index, tex_offset);

        is_left_dash = segment_is_dash(left_pattern_val.x);
        left_dist = dist_to_left_outside(tex_bias, left_pattern_val, pattern_scale);
    }
    // if dot on the left
    else
    {
        is_left_dash = false;
        left_dist = abs(dist);
    }
}
void get_dist_to_right_dot(float tex_bias, uint tex_offset, uint pattern_index, float2 pattern_val, float pattern_scale,
    float dist, out bool is_right_dash, out float right_dist)
{
    // if dot on the right.
    if (dist < 0.0f)
    {
        is_right_dash = false;
        right_dist = abs(dist);
    }
    // if dot on the left
    else
    {
        //  check if right segment is dash or dot.
        tex_offset = get_real_tex_offset_right(tex_offset);
        float2 right_pattern_val = load_pattern_val(pattern_index, tex_offset);

        is_right_dash = segment_is_dash(right_pattern_val.y);

        // compute distance to right segment.
        right_dist = dist_to_right_outside(tex_bias, right_pattern_val, pattern_scale);
    }

}

void get_hatch_dist_to_left_dot(float tex_bias, uint tex_offset, uint pattern_index, float2 pattern_val, float pattern_scale,
    float dist, out bool is_left_dash, out float left_dist)
{
    // if dot on the right.
    if (dist < 0.0f)
    {
        // check if left segment is dash or dot.
        tex_offset = get_real_tex_offset_left(tex_offset);
        float2 left_pattern_val = load_hatch_pattern_val(pattern_index, tex_offset);

        is_left_dash = segment_is_dash(left_pattern_val.x);
        left_dist = dist_to_left_outside(tex_bias, left_pattern_val, pattern_scale);
    }
    // if dot on the left
    else
    {
        is_left_dash = false;
        left_dist = abs(dist);
    }
}
void get_hatch_dist_to_right_dot(float tex_bias, uint tex_offset, uint pattern_index, float2 pattern_val, float pattern_scale,
    float dist, out bool is_right_dash, out float right_dist)
{
    // if dot on the right.
    if (dist < 0.0f)
    {
        is_right_dash = false;
        right_dist = abs(dist);
    }
    // if dot on the left
    else
    {
        //  check if right segment is dash or dot.
        tex_offset = get_real_tex_offset_right(tex_offset);
        float2 right_pattern_val = load_hatch_pattern_val(pattern_index, tex_offset);

        is_right_dash = segment_is_dash(right_pattern_val.y);

        // compute distance to right segment.
        right_dist = dist_to_right_outside(tex_bias, right_pattern_val, pattern_scale);
    }
}

void get_dist_to_left_right_dot(float tex_bias, uint tex_offset, uint pattern_index, float2 pattern_val, float pattern_scale,
    out bool is_left_dash, out float left_dist, out bool is_right_dash, out float right_dist)
{
    // compute distance to dot.
    float dist = dist_to_dot(tex_bias, pattern_val, pattern_scale);

    get_dist_to_left_dot(tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale, dist,
        is_left_dash, left_dist);
    get_dist_to_right_dot(tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale, dist,
        is_right_dash, right_dist);
}

void get_dist_to_left_right(float accum_len, float tex_bias, uint tex_offset, uint pattern_index, float2 pattern_val, float pattern_scale,
    out bool is_left_dash, out float left_dist, out bool is_right_dash, out float right_dist)
{
    // accum_len less than 1.0 means on a dot.
    if (is_pixel_on_dot(accum_len)) // dot
    {
        get_dist_to_left_right_dot(tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale,
            is_left_dash, left_dist, is_right_dash, right_dist);
    }
    else // space
    {
        get_dist_to_left_right_space(tex_bias, pattern_val, pattern_scale,
            is_left_dash, left_dist, is_right_dash, right_dist);
    }
}

void get_hatch_dist_to_left_right_dot(float tex_bias, uint tex_offset, uint pattern_index, float2 pattern_val, float pattern_scale,
    out bool is_left_dash, out float left_dist, out bool is_right_dash, out float right_dist)
{
    // compute distance to dot.
    float dist = dist_to_dot(tex_bias, pattern_val, pattern_scale);

    get_hatch_dist_to_left_dot(tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale, dist,
        is_left_dash, left_dist);
    get_hatch_dist_to_right_dot(tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale, dist,
        is_right_dash, right_dist);
}

void get_hatch_dist_to_left_right(float accum_len, float tex_bias, uint tex_offset, uint pattern_index, float2 pattern_val, float pattern_scale,
    out bool is_left_dash, out float left_dist, out bool is_right_dash, out float right_dist)
{
    // accum_len less than 1.0 means on a dot.
    if (is_pixel_on_dot(accum_len)) // dot
    {
        get_hatch_dist_to_left_right_dot(tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale,
            is_left_dash, left_dist, is_right_dash, right_dist);
    }
    else // space
    {
        get_dist_to_left_right_space(tex_bias, pattern_val, pattern_scale,
            is_left_dash, left_dist, is_right_dash, right_dist);
    }
}

void get_dist_to_left(float accum_len, float tex_bias, uint tex_offset, uint pattern_index, float2 pattern_val, float pattern_scale,
    out bool is_left_dash, out float left_dist)
{
    // accum_len less than 1.0 means on a dot.
    if (is_pixel_on_dot(accum_len)) // dot
    {
        float dist = dist_to_dot(tex_bias, pattern_val, pattern_scale);

        get_dist_to_left_dot(tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale, dist,
            is_left_dash, left_dist) ;
    }
    else // space
    {
        get_dist_to_left_space(tex_bias, pattern_val, pattern_scale,
            is_left_dash, left_dist);
    }
}
void get_dist_to_right(float accum_len, float tex_bias, uint tex_offset, uint pattern_index, float2 pattern_val, float pattern_scale,
     out bool is_right_dash, out float right_dist)
{
    // accum_len less than 1.0 means on a dot.
    if (is_pixel_on_dot(accum_len)) // dot
    {
        float dist = dist_to_dot(tex_bias, pattern_val, pattern_scale);

        get_dist_to_right_dot(tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale, dist,
             is_right_dash, right_dist);
    }
    else // space
    {
        get_dist_to_right_space(tex_bias, pattern_val, pattern_scale,
            is_right_dash, right_dist);
    }
}

int get_left_seg_type(bool is_left_dash, float left_dist, float dot_dist, float start_dist, float in_dist, 
    float2 start_pos, float line_dir, inout WideLinePatternResult left_attr)
{
    int res;
    // if left is dash
    if (is_left_dash)
    {
        // if inside dash, return dash.
        if (left_dist < 0.0f)
        {
            res = PURE_DASH;
        }
        // if inside left caps range.
        else if ((left_dist <= dot_dist) && (left_dist <= start_dist + 0.5f))
        {
            left_attr.is_caps = true;
            left_attr.dist = sqrt(left_dist*left_dist + in_dist*in_dist);
            left_attr.caps_center = start_pos + line_dir*(start_dist - left_dist);
            left_attr.caps_dir = line_dir;

            res = MIXED;
        }
        // if insdie space.
        else
        {
            left_attr.dist = -1.0f;

            res = PURE_SPACE;
        }
    }
    else
    {
        // if inside left dot range or close to start point.
        if ((abs(left_dist) <= dot_dist) && (left_dist <= start_dist + 0.5f))
        {
            left_attr.dist = sqrt(in_dist*in_dist + left_dist*left_dist);
            res = MIXED;
        }
        // if inside space.
        else
        {
            left_attr.dist = -1.0f;
            res = PURE_SPACE;
            
        }
    }

    return res;
}

// When it is a dot, we need ensure the dot is in the line region.
// For left res,  need meet the condition 0 < startDist - leftDist < length 
//      => -startDist < -leftDist < length - startDist
//      => -startDist < -leftDist < endDist
//      => -endDist < leftDist < startDist
//      => -test_dist2 < leftDist < test_dist
// For right res, need meet the condition 0 < startDist + rightDist < length
//      => -startDist < rightDist < length - startDist
//      => -startDist < rightDist < endDist
//      => -test_dist2 < rightDist < test_dist
int get_seg_type(bool is_dash, float dist, float dot_dist, float test_dist, float test_dist2, float in_dist, float bias,
    float2 ref_pos, float2 line_dir, inout WideLinePatternResult attr)
{
    int res;
    // if right is a dash.
    if (is_dash)
    {
        // if inside dash.
        if (dist <= 0.0f)
        {
            res = PURE_DASH;
        }
        // if inside right segment caps range.
        else if ((dist <= dot_dist) && (dist < test_dist+bias))
        {
            attr.is_caps = true;
            attr.dist = sqrt(dist*dist + in_dist*in_dist);

            attr.caps_center = ref_pos + line_dir*(test_dist - dist);
            attr.caps_dir = line_dir;

            res = MIXED;
        }
        // if inside space.
        else
        {
            res = PURE_SPACE;
            attr.dist = -1.0f;
        }
    }
    // if right is dot.
    else
    {
        // if inside dot range or close to end point.
        if ((abs(dist) <= dot_dist) && (dist < test_dist+bias) && (dist > -1*test_dist2-bias))
        {
            attr.dist = sqrt(in_dist*in_dist + dist*dist);
            res = MIXED;
        }
        // if inside space.
        else
        {
            res = PURE_SPACE;
            attr.dist = -1.0f;
        }
    }

    return res;
}

int get_right_seg_type(bool is_right_dash, float right_dist, float dot_dist, float end_dist, float in_dist,
    float2 end_pos, float line_dir, inout WideLinePatternResult right_attr)
{
    int res;
    // if right is a dash.
    if (is_right_dash)
    {
        // if inside dash.
        if (right_dist <= 0.0f)
        {
            res = PURE_DASH;
        }
        // if inside right segment caps range.
        else if ((right_dist <= dot_dist) && (right_dist < end_dist))
        {
            right_attr.is_caps = true;
            right_attr.dist = sqrt(right_dist*right_dist + in_dist*in_dist);

            right_attr.caps_center = end_pos - line_dir*(end_dist - right_dist);
            right_attr.caps_dir = -line_dir;

            res = MIXED;
        }
        // if inside space.
        else
        {
            res = PURE_SPACE;
            right_attr.dist = -1.0f;
        }
    }
    // if right is dot.
    else
    {
        // if inside dot range or close to end point.
        if ((abs(right_dist) <= dot_dist) && (right_dist < end_dist))
        {
            right_attr.dist = sqrt(in_dist*in_dist + right_dist*right_dist);
            res = MIXED;
        }
        // if inside space.
        else
        {
            res = PURE_SPACE;
            right_attr.dist = -1.0f;
        }
    }

    return res;
}

bool left_dot_in_start_skip_len(float start_dist, float left_dist, float start_skip_len, float bias)
{
    return start_dist - left_dist <= start_skip_len + bias;
}
bool left_dot_in_end_skip_len(float end_dist, float left_dist, float end_skip_len, float bias)
{
    return end_dist + left_dist <= end_skip_len + bias;
}

bool right_dot_in_start_skip_len(float start_dist, float right_dist, float start_skip_len, float bias)
{
    return (start_dist + right_dist <= start_skip_len + bias);
}

bool right_dot_in_end_skip_len(float end_dist, float right_dist, float end_skip_len, float bias)
{
    return (end_dist - right_dist <= end_skip_len + bias);
}

void adjust_for_out_of_start_dot(float start_dist, float start_skip_len, float dot_dist, bool has_prev_line, float in_dist,
    inout float out_dist, inout int res)
{
    if (start_dist <= dot_dist)
    {
        // if pline gen off.
        if (!is_pline_gen(start_skip_len))
        {
            // has previous line segment, ignore the dot.
            if (has_prev_line)
            {
                out_dist = -1.0f;
                res = PURE_SPACE;
            }
            // otherwise we draw dot.
            else if (res != MIXED)
            {
                out_dist = sqrt(in_dist*in_dist + start_dist*start_dist);
                res = MIXED;
            }
        }
    }
}
void adjust_for_out_of_end_dot(float end_dist, float end_skip_len, float dot_dist, bool has_post_line, float in_dist,
    inout float out_dist, inout int res)
{
    if (end_dist <= dot_dist)
    {
        // if pline gen off.
        if (!is_pline_gen(end_skip_len))
        {
            // if has a previous line, ignore the dot.
            if (has_post_line)
            {
                out_dist = -1.0f;
                res = PURE_SPACE;
            }
            // otherwise we draw dot.
            else if (res != MIXED)
            {
                out_dist = sqrt(in_dist*in_dist + end_dist*end_dist);
                res = MIXED;
            }
        }
    }
}


// check line type pattern for wide line.
int check_wide_line_pattern(
    WideLinePatternAttr attr,
    WideLineInfo info,

    out WideLinePatternResult left_attr,
    out WideLinePatternResult right_attr)
{
    // init input parameter
    float in_dist = attr.dist;
    float in_width = attr.width;
    float start_dist = attr.startDist;
    float end_dist = attr.endDist;
    float start_skip_len = attr.startSkipLen;
    float end_skip_len = attr.endSkipLen;
    float pattern_scale = attr.patternScale;
    float pattern_offset = attr.patternOffset;
    uint pattern_index = attr.patternIndex;

    float2 start_pos = info.startPos;
    float2 end_pos = info.endPos;
    float2 line_dir = info.lineDir;
    bool has_prev_line = info.hasPrevLine;
    bool has_post_line = info.hasPostLine;

    // intialize output structure.
    init_wide_line_pattern_attr(left_attr);
    init_wide_line_pattern_attr(right_attr);

    // get pattern sclae value, ignore sign bit. 
    pattern_scale = get_real_pattern_scale(pattern_scale);

    // compute the dot size.
    float dot_dist = get_dot_size(in_width);

    // get pure dot flag.
    bool is_pure_dot = is_pure_dot_pattern(pattern_index);
    // get line pattern index from low 31-bits of pattern_index.
    pattern_index = get_real_pattern_index(pattern_index);

    // scale = 0.0 means continues line type
    if (is_continue_pattern(pattern_scale))
        return PURE_DASH;

    // if is not pure dot pattern.
    if (!is_pure_dot)
    {
        if (in_wide_dash_skip_len(start_dist, start_skip_len, end_dist, end_skip_len))
            return PURE_DASH;
    }

   

    // compute texture coordinate of pattern texture.
    float pattern_pos = (start_dist - start_skip_len) * pattern_scale + pattern_offset;
    uint tex_offset = uint(pattern_pos);
    float tex_bias = pattern_pos - tex_offset;

    // repeat the pattern when there are one more pattern on a line.
    tex_offset = get_real_tex_offset(tex_offset);

    // sample pattern value.
    float2 pattern_val = load_pattern_val(pattern_index, tex_offset);

    // accum_len = 0.0 means on dash.
    float accum_len = abs(pattern_val.x) + abs(pattern_val.y);

    if (is_pixel_on_dash(accum_len))
    {
        return PURE_DASH;
    }

    // get distance to left segment and right segment
    float left_dist, right_dist;
    bool is_left_dash, is_right_dash;

    get_dist_to_left_right(accum_len, tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale,
        is_left_dash, left_dist, is_right_dash, right_dist);

    int left_res = get_seg_type(is_left_dash, left_dist, dot_dist, start_dist, end_dist, in_dist, 0.0f,
        start_pos, line_dir, left_attr);

    if (left_res == PURE_DASH)
        return PURE_DASH;
    
    int right_res = get_seg_type(is_right_dash, right_dist, dot_dist, end_dist, start_dist, in_dist, 0.0f,
        end_pos, -line_dir, right_attr);

    if (right_res == PURE_DASH)
        return PURE_DASH;

   
    // if is pure dot
    if (is_pure_dot)
    {
        // left dot inside start skip len or end skip len, ignore the dot. 
        if (left_dot_in_start_skip_len(start_dist, left_dist, start_skip_len, 0.45f) ||
            left_dot_in_end_skip_len(end_dist, left_dist, end_skip_len, 0.45f))
        {
            left_res = PURE_SPACE;
            left_attr.dist = -1.0f;
        }
        // right dot inside start skip len or end skip len, ignore the dot.
        if (right_dot_in_end_skip_len(end_dist, right_dist, end_skip_len, 0.45f) ||
            right_dot_in_start_skip_len(start_dist, right_dist, start_skip_len, 0.45f))
        {
            right_res = PURE_SPACE;
            right_attr.dist = -1.0f;
        }

        // current pixel inside a dot out of start point of line.
        adjust_for_out_of_start_dot(start_dist, start_skip_len, dot_dist, has_prev_line, in_dist,
            left_attr.dist, left_res);
       
        // current pixel inside a dot out of end point of line.
        adjust_for_out_of_end_dot(end_dist, end_skip_len, dot_dist, has_post_line, in_dist,
            right_attr.dist, right_res);
    }

    // if both left and right are in space, draw as space.
    if ((left_res == PURE_SPACE) && (right_res == PURE_SPACE))
        return PURE_SPACE;

    // return mixed and let pixel shader compute mixed color.
    return MIXED;
}

// check line type pattern for wide line.
int check_hatch_wide_line_pattern(
    WideLinePatternAttr attr,
    WideLineInfo info,
    out WideLinePatternResult left_attr,
    out WideLinePatternResult right_attr)
{
    // init input parameter
    float in_dist = attr.dist;
    float in_width = attr.width;
    float start_dist = attr.startDist;
    float end_dist = attr.endDist;
    float start_skip_len = attr.startSkipLen;
    float end_skip_len = attr.endSkipLen;
    float pattern_scale = attr.patternScale;
    float pattern_offset = attr.patternOffset;
    uint pattern_index = attr.patternIndex;

    float2 start_pos = info.startPos;
    float2 end_pos = info.endPos;
    float2 line_dir = info.lineDir;

    // intialize output structure.
    init_wide_line_pattern_attr(left_attr);
    init_wide_line_pattern_attr(right_attr);

    // get pattern sclae value, ignore sign bit. 
    pattern_scale = get_real_pattern_scale(pattern_scale);

    // compute the dot size.
    float dot_dist = get_dot_size(in_width);

    // get line pattern index from low 31-bits of pattern_index.
    pattern_index = get_real_pattern_index(pattern_index);

    // scale = 0.0 means continues line type
    if (is_continue_pattern(pattern_scale))
        return PURE_DASH;

    // compute texture coordinate of pattern texture.
    float pattern_pos = (start_dist - start_skip_len) * pattern_scale + pattern_offset;
    uint tex_offset = uint(pattern_pos);
    float tex_bias = pattern_pos - tex_offset;

    // repeat the pattern when there are one more pattern on a line.
    tex_offset = get_real_tex_offset(tex_offset);

    // sample pattern value.
    float2 pattern_val = load_hatch_pattern_val(pattern_index, tex_offset);

    // accum_len = 0.0 means on dash.
    float accum_len = abs(pattern_val.x) + abs(pattern_val.y);

    if (is_pixel_on_dash(accum_len))
    {
        return PURE_DASH;
    }

    // get distance to left segment and right segment
    float left_dist, right_dist;
    bool is_left_dash, is_right_dash;

    get_hatch_dist_to_left_right(accum_len, tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale,
        is_left_dash, left_dist, is_right_dash, right_dist);

    int left_res = get_seg_type(is_left_dash, left_dist, dot_dist, start_dist, end_dist, in_dist, 0.0001f,
        start_pos, line_dir, left_attr);

    if (left_res == PURE_DASH)
        return PURE_DASH;

    int right_res = get_seg_type(is_right_dash, right_dist, dot_dist, end_dist, start_dist, in_dist, 0.0001f,
        end_pos, -line_dir, right_attr);

    if (right_res == PURE_DASH)
        return PURE_DASH;

    // Fix compiler err, whithout this, when right_res is PURE_DASH, it will return MIXED.
    if (right_res == MIXED || left_res == MIXED)
        return MIXED;

    // if both left and right are in space, draw as space.
    if ((left_res == PURE_SPACE) && (right_res == PURE_SPACE))
        return PURE_SPACE;

    // return mixed and let pixel shader compute mixed color.
    return MIXED;
}

struct WideEllipseInfo
{
    bool inverted;
    float2 radius;
    float2 range;
    bool hasPrevLine;
    bool hasPostLine;
    bool isCircle;
    float  curAngle;
};

int get_left_seg_type_arc(bool is_left_dash, float left_dist, float dot_dist, float start_dist, float in_dist,
    bool is_circle, bool lt_inverted, float2 radius, float2 range, float cur_angle,
    inout WideLinePatternResult left_attr)
{
    int res;

    if (is_left_dash)
    {
        if (left_dist < 0.0f)
        {
            res = PURE_DASH;
        }
        else if ((left_dist <= dot_dist) && (left_dist <= start_dist + 0.5f))
        {
            left_attr.is_caps = true;
            left_attr.dist = sqrt(left_dist*left_dist + in_dist*in_dist);

            if (is_circle)
            {
                if (lt_inverted)
                {
                    // compute caps center/dir.
                    float angle = range.y - (start_dist - left_dist) / radius.x;
                    left_attr.caps_center = float2(radius.x*cos(angle), radius.x * sin(angle));
                    left_attr.caps_dir = -1 * normalize(float2(1, left_attr.caps_center.y - left_attr.caps_center.x*(1 - left_attr.caps_center.x) / left_attr.caps_center.y));
                }
                else
                {
                    // compute caps center/dir.
                    float angle = range.x + (start_dist - left_dist) / radius.x;
                    left_attr.caps_center = float2(radius.x*cos(angle), radius.x * sin(angle));
                    left_attr.caps_dir = normalize(float2(1, left_attr.caps_center.y - left_attr.caps_center.x*(1 - left_attr.caps_center.x) / left_attr.caps_center.y));
                }
            }
            else
            {
                float s, c;
                sincos(cur_angle, s, c);

                float2 cur_pos = float2(radius.x*c, radius.y*s);
                float2 cur_tan = normalize(float2(-radius.x*s, radius.y*c));

                // for ellipse
                if (lt_inverted)
                {
                    left_attr.caps_center = cur_pos + left_dist*cur_tan;
                    left_attr.caps_dir = -cur_tan;
                }
                else
                {
                    left_attr.caps_center = cur_pos - left_dist*cur_tan;
                    left_attr.caps_dir = cur_tan;

                }
            }


            res = MIXED;
        }
        else
        {
            res = PURE_SPACE;
            left_attr.dist = -1.0f;
        }
    }
    else
    {
        if ((abs(left_dist) <= dot_dist) && (left_dist <= start_dist + 0.5f))
        {
            left_attr.dist = sqrt(in_dist*in_dist + left_dist*left_dist);
            res = MIXED;
        }
        else
        {
            res = PURE_SPACE;
            left_attr.dist = -1.0f;
        }
    }

    return res;
}

int get_right_seg_type_arc(bool is_right_dash, float right_dist, float dot_dist, float end_dist, float in_dist,
    bool is_circle, bool lt_inverted, float2 radius, float2 range, float cur_angle,
    inout WideLinePatternResult right_attr)
{
    int res;

    if (is_right_dash)
    {
        if (right_dist <= 0.0f)
        {
            res = PURE_DASH;
        }
        else if (right_dist <= dot_dist && right_dist < end_dist)
        {
            right_attr.is_caps = true;
            right_attr.dist = sqrt(right_dist*right_dist + in_dist*in_dist);

            if (is_circle)
            {
                if (lt_inverted) {
                    // compute caps center dir.
                    float angle = range.x + (end_dist - right_dist) / radius.x;
                    right_attr.caps_center = float2(radius.x*cos(angle), radius.x * sin(angle));
                    right_attr.caps_dir = normalize(float2(1, right_attr.caps_center.y - right_attr.caps_center.x *(1 - right_attr.caps_center.x) / right_attr.caps_center.y));
                }
                else {
                    // compute caps center dir.
                    float angle = range.y - (end_dist - right_dist) / radius.x;
                    right_attr.caps_center = float2(radius.x*cos(angle), radius.x * sin(angle));
                    right_attr.caps_dir = -1 * normalize(float2(1, right_attr.caps_center.y - right_attr.caps_center.x *(1 - right_attr.caps_center.x) / right_attr.caps_center.y));
                }
            }
            else
            {
                // for ellipse
                float s, c;
                sincos(cur_angle, s, c);

                float2 cur_pos = float2(radius.x*c, radius.y*s);
                float2 cur_tan = normalize(float2(-radius.x*s, radius.y*c));

                // for ellipse
                if (lt_inverted)
                {
                    right_attr.caps_center = cur_pos - right_dist*cur_tan;
                    right_attr.caps_dir = cur_tan;
                }
                else
                {
                    right_attr.caps_center = cur_pos + right_dist*cur_tan;
                    right_attr.caps_dir = -cur_tan;

                }
            }


            res = MIXED;
        }
        else
        {
            res = PURE_SPACE;
            right_attr.dist = -1.0f;
        }
    }
    else
    {
        if ((abs(right_dist) <= dot_dist) && (right_dist < end_dist))
        {
            right_attr.dist = sqrt(in_dist*in_dist + right_dist*right_dist);
            res = MIXED;
        }
        else
        {
            res = PURE_SPACE;
            right_attr.dist = -1.0f;
        }
    }

    return res;
}

void adjust_nearly_closed_arc(float end_dist, float dot_dist, float in_dist, float2 radius, float2 range,
    inout WideLinePatternResult right_attr, inout int right_res)
{
    if (right_res == PURE_SPACE
        && end_dist <= dot_dist
        && abs(range.y - range.x) > (TWO_PI - 0.01f))
    {
        // force add a cap for the end dot/dash.
        right_attr.is_caps = true;
        right_attr.dist = sqrt(end_dist*end_dist + in_dist*in_dist);
        right_attr.caps_center = float2(radius.x, 0);
        right_attr.caps_dir = float2(0, -1);
        right_res = MIXED;

    }
}


// check line type pattern for wide line arc.
int check_widearc_line_pattern(WideLinePatternAttr attr,
    WideEllipseInfo info,
    float glowWidth,

    out WideLinePatternResult left_attr,
    out WideLinePatternResult right_attr
    )
{
    // init input parameter
    float in_dist = attr.dist;
    float in_width = attr.width;
    float start_dist = attr.startDist;
    float end_dist = attr.endDist;
    float start_skip_len = attr.startSkipLen;
    float end_skip_len = attr.endSkipLen;
    float pattern_scale = attr.patternScale;
    float pattern_offset = attr.patternOffset;
    uint pattern_index = attr.patternIndex;

    bool lt_inverted = info.inverted;
    float2 radius = info.radius;
    float2 range = info.range;
    bool has_prev_line = info.hasPrevLine;
    bool has_post_line = info.hasPostLine;
    bool is_circle = info.isCircle;
    float  cur_angle = info.curAngle;
   
    // init output results
    init_wide_line_pattern_attr(left_attr);
    init_wide_line_pattern_attr(right_attr);

    // get pattern sclae value, ignore sign bit. 
    pattern_scale = get_real_pattern_scale(pattern_scale);

    // compute the dot size.
    float dot_dist = get_dot_size(in_width);

    // get pure dot flag.
    bool is_pure_dot = is_pure_dot_pattern(pattern_index);
    // get line pattern index from low 31-bits of pattern_index.
    pattern_index = get_real_pattern_index(pattern_index);

    // scale = 0.0 means continues line type
    if (is_continue_pattern(pattern_scale))
        return PURE_DASH;

    // if is not pure dot pattern.
    if (!is_pure_dot)
    {
        if (in_wide_dash_skip_len(start_dist, start_skip_len, end_dist, end_skip_len))
            return PURE_DASH;
    }

   

    // compute texture coordinate of pattern texture.
    float pattern_pos = (start_dist - start_skip_len) * pattern_scale + pattern_offset;
    uint tex_offset = uint(pattern_pos);
    float tex_bias = pattern_pos - tex_offset;

    // repeat the pattern when there are one more pattern on a line.
    tex_offset = get_real_tex_offset(tex_offset);

    // sample pattern value.
    float2 pattern_val = load_pattern_val(pattern_index, tex_offset);

    // accum_len = 0.0 means on dash.
    float accum_len = abs(pattern_val.x) + abs(pattern_val.y);

    if (is_pixel_on_dash(accum_len))
    {
        return PURE_DASH;
    }

    // get distance to left segment and right segment
    float left_dist, right_dist;
    bool is_left_dash, is_right_dash;

    get_dist_to_left_right(accum_len, tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale,
        is_left_dash, left_dist, is_right_dash, right_dist);

    int left_res = get_left_seg_type_arc(is_left_dash, left_dist, dot_dist, start_dist, in_dist,
        is_circle, lt_inverted, radius, range, cur_angle, left_attr);

    if (left_res == PURE_DASH)
        return PURE_DASH;

    int right_res = get_right_seg_type_arc(is_right_dash, right_dist, dot_dist, end_dist, in_dist,
        is_circle, lt_inverted, radius, range, cur_angle, right_attr);

    if (right_res == PURE_DASH)
        return PURE_DASH;

    
    if (is_pure_dot)
    {
        // left dot inside start skip len or end skip len, ignore the dot. 
        if (left_dot_in_start_skip_len(start_dist, left_dist, start_skip_len, 0.45f) ||
            left_dot_in_end_skip_len(end_dist, left_dist, end_skip_len, 0.45f))
        {
            left_res = PURE_SPACE;
            left_attr.dist = -1.0f;
        }
        // right dot inside start skip len or end skip len, ignore the dot.
        if (right_dot_in_end_skip_len(end_dist, right_dist, end_skip_len, 0.45f) ||
            right_dot_in_start_skip_len(start_dist, right_dist, start_skip_len, 0.45f))
        {
            right_res = PURE_SPACE;
            right_attr.dist = -1.0f;
        }

        // current pixel inside a dot out of start point of line.
        adjust_for_out_of_start_dot(start_dist, start_skip_len, dot_dist, has_prev_line, in_dist,
            left_attr.dist, left_res);

        // current pixel inside a dot out of end point of line.
        adjust_for_out_of_end_dot(end_dist, end_skip_len, dot_dist, has_post_line, in_dist,
            right_attr.dist, right_res);

    }

    // if it's an almost close circle/ellipse
    adjust_nearly_closed_arc(end_dist, dot_dist, in_dist, radius, range,
        right_attr, right_res);

    if ((left_res == PURE_SPACE) && (right_res == PURE_SPACE))
        return PURE_SPACE;

    return MIXED;
}

bool check_point_on_dash(
    float2 start_point,
    float2 end_point,
    float2 cur_point,
    uint pattern_index,
    float4 pattern_prop,
    float width)
{
    // intialize parameters
    float start_skip_len = pattern_prop.x;
    float end_skip_len = pattern_prop.y;
    float pattern_scale = abs(pattern_prop.z);
    float pattern_offset = pattern_prop.w;

    // get pattern index
    bool is_pure_dot = is_pure_dot_pattern(pattern_index);
    pattern_index = get_real_pattern_index(pattern_index);

    // get distances
    float start_dist = dot(cur_point - start_point, normalize(end_point - start_point));
    float end_dist = dot(cur_point - end_point, normalize(start_point - end_point));

    // check skip len
    if (!is_pure_dot)
    {
        if (in_dash_skip_len(abs(start_dist), start_skip_len,
            abs(end_dist), end_skip_len))
            return true;
    }

    // load pattern value
    float pattern_pos = (start_dist - start_skip_len) * pattern_scale + pattern_offset;
    uint tex_offset = uint(pattern_pos);
    float tex_bias = pattern_pos - tex_offset;
    tex_offset = get_real_tex_offset(tex_offset);
    float2 pattern_val = load_pattern_val(pattern_index, tex_offset);

    // get accume len
    float accum_len = abs(pattern_val.x) + abs(pattern_val.y);

    if (is_pixel_on_dash(accum_len)) // dash
        return true;

    if (is_pixel_on_dot(accum_len)) // dot
    {
        float dist = dist_to_dot(tex_bias, pattern_val, pattern_scale);
        float left_dist, right_dist;


        if (dist < 0.0f) // dot on the right
        {
            right_dist = abs(dist);

            // load left pattern
            tex_offset = get_real_tex_offset_left(tex_offset);
            float2 left_pattern_val = load_pattern_val(pattern_index, tex_offset);

            left_dist = dist_to_left_outside(tex_bias, left_pattern_val, pattern_scale);
        }
        else // dot on the left
        {
            left_dist = abs(dist);

            // load right pattern
            tex_offset = get_real_tex_offset_right(tex_offset);
            float2 right_pattern_val = load_pattern_val(pattern_index, tex_offset);

            right_dist = dist_to_right_outside(tex_bias, right_pattern_val, pattern_scale);
        }
        accum_len = left_dist + right_dist;
    }

    if (is_dash_too_short(accum_len, pattern_scale, width))
        return true;

    // space
    if (pattern_val.x < 0.0f) // left is dash
    {
        if (1.0 - tex_bias >= abs(pattern_val.x) - 0.5*pattern_scale)
            return true;
    }

    if (pattern_val.y < 0.0f) // right is dash
    {
        if (tex_bias >= abs(pattern_val.y) - 0.5*pattern_scale)
            return true;
    }


    return false;
}

bool check_joint_point_on_dash(
    float2 prev_pnt,
    float2 cur_pnt,
    float2 post_pnt,
    uint pattern_index,
    float4 prevProp,
    float4 postProp,
    float width
    )
{
    if ((!is_pline_gen(prevProp.y)) || (!is_pline_gen(postProp.x)))
        return true;

    bool on_prev_dash = check_point_on_dash(prev_pnt, cur_pnt, cur_pnt, pattern_index, prevProp, width);
    bool on_post_dash = check_point_on_dash(cur_pnt, post_pnt, cur_pnt, pattern_index, postProp, width);

    if (on_prev_dash && on_post_dash)
        return true;

    return false;

}


struct WideJointInfo
{
    float2 curPoint;
    float dist;
    float width;
    float2 startPoint;
    float2 endPoint;
};

bool out_of_line(float dist)
{
    return dist < 0.0f;
}

bool out_of_line_region(float start_dist, float end_dist)
{
    return out_of_line(start_dist) || out_of_line(end_dist);
}

int check_wide_line_pattern_left(
    WideJointInfo info,
    float4 patternProp,
    uint pattern_index,
    out WideLinePatternResult left_attr
    )
{
    left_attr = (WideLinePatternResult)0;

    // initialize parameters
    float2 cur_pnt = info.curPoint;
    float in_dist = info.dist;
    float in_width = info.width;
    float2 start_pnt = info.startPoint;
    float2 end_pnt = info.endPoint;

    float start_skip_len = patternProp.x;
    float end_skip_len = patternProp.y;
    float pattern_scale = patternProp.z;
    float pattern_offset = patternProp.w;

    // compute major values
    float2 start_pos = start_pnt;
    float2 end_pos = end_pnt;
    float2 line_dir = normalize(end_pos - start_pos);

    float start_dist = dot(cur_pnt - start_pnt, line_dir);
    float end_dist = dot(cur_pnt - end_pnt, -line_dir);

    if (out_of_line_region(start_dist, end_dist))
        return PURE_SPACE;

    init_wide_line_pattern_attr(left_attr);

    // get pattern sclae value, ignore sign bit. 
    pattern_scale = get_real_pattern_scale(pattern_scale);

    // compute the dot size.
    float dot_dist = get_dot_size(in_width);

    // get pure dot flag.
    bool is_pure_dot = is_pure_dot_pattern(pattern_index);
    // get line pattern index from low 31-bits of pattern_index.
    pattern_index = get_real_pattern_index(pattern_index);

    // scale = 0.0 means continues line type
    if (is_continue_pattern(pattern_scale))
        return PURE_DASH;

    // if is not pure dot pattern.
    if (!is_pure_dot)
    {
        if (in_wide_dash_skip_len(start_dist, start_skip_len, end_dist, end_skip_len))
            return PURE_DASH;
    }
    
    // compute texture coordinate of pattern texture.
    float pattern_pos = (start_dist - start_skip_len) * pattern_scale + pattern_offset;
    uint tex_offset = uint(pattern_pos);
    float tex_bias = pattern_pos - tex_offset;

    // repeat the pattern when there are one more pattern on a line.
    tex_offset = get_real_tex_offset(tex_offset);

    // sample pattern value.
    float2 pattern_val = load_pattern_val(pattern_index, tex_offset);

    // accum_len = 0.0 means on dash.
    float accum_len = abs(pattern_val.x) + abs(pattern_val.y);

    if (is_pixel_on_dash(accum_len))
    {
        return PURE_DASH;
    }


    float left_dist;
    bool is_left_dash;

    get_dist_to_left(accum_len, tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale,
        is_left_dash, left_dist);

    int left_res = get_seg_type(is_left_dash, left_dist, dot_dist, start_dist, end_dist, in_dist, 0.5f,
        start_pos, line_dir, left_attr);

    if (left_res == PURE_DASH)
        return PURE_DASH;

   
    if (is_pure_dot)
    {        
        if (left_dot_in_start_skip_len(start_dist, left_dist, start_skip_len, -0.3f) ||
            left_dot_in_end_skip_len(end_dist, left_dist, end_skip_len, in_width*0.5f - 0.3f))
        {
            left_res = PURE_SPACE;
            left_attr.dist = -1.0f;
        }

        // current pixel inside a dot out of start point of line.
        adjust_for_out_of_start_dot(start_dist, start_skip_len, dot_dist, false, in_dist,
            left_attr.dist, left_res);
    }

    return left_res;
}


int check_wide_line_pattern_right(
    WideJointInfo info,
    float4 patternProp,
    uint pattern_index,
    out WideLinePatternResult right_attr
    )
{
    right_attr = (WideLinePatternResult)0;
    // initialize parameters
    float2 cur_pnt = info.curPoint;
    float in_dist = info.dist;
    float in_width = info.width;
    float2 start_pnt = info.startPoint;
    float2 end_pnt = info.endPoint;

    float start_skip_len = patternProp.x;
    float end_skip_len = patternProp.y;
    float pattern_scale = abs(patternProp.z);
    float pattern_offset = patternProp.w;

    // compute major values
    float2 start_pos = start_pnt;
    float2 end_pos = end_pnt;
    float2 line_dir = normalize(end_pos - start_pos);

    float start_dist = dot(cur_pnt - start_pnt, line_dir);
    float end_dist = dot(cur_pnt - end_pnt, -line_dir);

    if (out_of_line_region(start_dist, end_dist))
        return PURE_SPACE;

    init_wide_line_pattern_attr(right_attr);

    // get pattern sclae value, ignore sign bit. 
    pattern_scale = get_real_pattern_scale(pattern_scale);

    // compute the dot size.
    float dot_dist = get_dot_size(in_width);

    // get pure dot flag.
    bool is_pure_dot = is_pure_dot_pattern(pattern_index);
    // get line pattern index from low 31-bits of pattern_index.
    pattern_index = get_real_pattern_index(pattern_index);

    // scale = 0.0 means continues line type
    if (is_continue_pattern(pattern_scale))
        return PURE_DASH;

    // if is not pure dot pattern.
    if (!is_pure_dot)
    {
        if (in_wide_dash_skip_len(start_dist, start_skip_len, end_dist, end_skip_len))
            return PURE_DASH;
    }

    // compute texture coordinate of pattern texture.
    float pattern_pos = (start_dist - start_skip_len) * pattern_scale + pattern_offset;
    uint tex_offset = uint(pattern_pos);
    float tex_bias = pattern_pos - tex_offset;

    // repeat the pattern when there are one more pattern on a line.
    tex_offset = get_real_tex_offset(tex_offset);

    // sample pattern value.
    float2 pattern_val = load_pattern_val(pattern_index, tex_offset);

    // accum_len = 0.0 means on dash.
    float accum_len = abs(pattern_val.x) + abs(pattern_val.y);

    if (is_pixel_on_dash(accum_len))
    {
        return PURE_DASH;
    }

    float  right_dist;
    bool is_right_dash;

    get_dist_to_left(accum_len, tex_bias, tex_offset, pattern_index, pattern_val, pattern_scale,
        is_right_dash, right_dist);

    int right_res = get_seg_type(is_right_dash, right_dist, dot_dist, end_dist, start_dist, in_dist, 0.0f,
        end_pos, -line_dir, right_attr);

    if (right_res == PURE_DASH)
        return PURE_DASH;

    if (is_pure_dot)
    {
        // right dot inside start skip len or end skip len, ignore the dot.
        if (right_dot_in_end_skip_len(end_dist, right_dist, end_skip_len,-0.3f) ||
            right_dot_in_start_skip_len(start_dist, right_dist, start_skip_len, in_width*0.5f-0.3f))
        {
            right_res = PURE_SPACE;
            right_attr.dist = -1.0f;
        }

        // current pixel inside a dot out of end point of line.
        adjust_for_out_of_end_dot(end_dist, end_skip_len, dot_dist, false, in_dist,
            right_attr.dist, right_res);
    }

    return right_res;
}

#endif
