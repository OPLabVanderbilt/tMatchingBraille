
function KbName_text(ptr,ctext,tcolor,yoffset)

if nargin<2; error('%%Usage: center_text(ptr,text,[color],[yoffset])')
elseif nargin<3; yoffset=0; tcolor=255;
elseif nargin<4; yoffset=0; 
end

rect=Screen('Rect',ptr); %%size of window
sx = RectWidth(rect); %width
sy = RectHeight(rect); %height

tw=Screen('TextBounds',ptr,ctext);
Screen('DrawText',ptr,ctext,round(sx/2)-round(tw(3)/2),...
    round(sy/2)+yoffset,tcolor);