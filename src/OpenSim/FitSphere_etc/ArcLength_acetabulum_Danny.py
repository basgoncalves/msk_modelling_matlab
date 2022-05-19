from skspatial.objects import Line
from skspatial.objects import Sphere

## calculate intersection acetabular sphere and hjcf, then calculate the arc length (i.e. spread acetabular loading)
# make sure coordinates (c and p) are in same coordinate system (e.g. femur cs)
# needed: HJCF (vx,vy,vz) and HJCF origin (px,py,pz), sphere center (cx,cy,cz), sphere radius (ace_radius)

p_intersect_gc = np.zeros((101)) 
for i in range(0,101):
    ac_sphere = Sphere([cx,cy,cz],ace_radius[isubj]) #cx,cy,cz = centre sphere 
    hjcf_line = Line([px,py,pz],[vx,vy,vz]) # px,py,pz = point that line goes through (e.g. origo hjcf) || vx,vy,vz = direction of vector/line (e.g. hjcf)
    point_a, point_b = ac_sphere.intersect_line(hjcf_line) 

    # choose most medial intersection (x < 0 for right, x > 0 for left) - at least in RAJA model
    if (leg == 'r' and point_a[0] < 0) or (leg == 'l' and point_a[0]>0):
        p_intersect = point_a
    elif (leg == 'r' and point_b[0] < 0) or (leg == 'l' and point_b[0]>0):
        p_intersect = point_b

    p_intersect_gc[i,:] = p_intersect - [cx,cy,cz] # translate to middle sphere 

# ## calc arc-length sphere (greater-circle distance)
# # https://math.stackexchange.com/questions/1304169/distance-between-two-points-on-a-sphere

# Acap = 2*np.pi*ace_radius*cup_depth # surface area acetabulum: only needed if you want to correct for the an individuals acetabulum size.     
dArcLength = np.zeros((101))
for i in range(0,101):
    alpha = np.arccos(np.dot(p_intersect_gc[i,:], np.mean(p_intersect_gc,0))/ace_radius**2)                 
    dArcLength[i] = ace_radius*alpha # / Acap # normalise to surface area cap (reduces variance comparing between people)