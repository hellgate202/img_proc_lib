#!/usr/bin/python3

import sys
import math

orig_resolution_x = int( sys.argv[1] )
orig_resolution_y = int( sys.argv[2] )
des_resolution_x = int( sys.argv[3] )
des_resolution_y = int( sys.argv[4] )

skip_pixels_x_list = []
interval_x_list = []
res_x_list = []
delta_x_list = []

for skip_pixels_x in range( 1, 100 ):
  for interval_x in range( 2, 100 ):
    if( interval_x <= skip_pixels_x ):
      continue
    interval_amount_x = math.ceil( orig_resolution_x / float( interval_x ) )
    full_interval_amount_x = math.floor( orig_resolution_x / float( interval_x ) )
    if( full_interval_amount_x != interval_amount_x ):
      px_in_last_interval_x = orig_resolution_x  - full_interval_amount_x * interval_x
      if( px_in_last_interval_x > ( interval_x - skip_pixels_x ) ):
        px_in_last_interval_x = interval_x - skip_pixels_x
    else:
      px_in_last_interval_x = 0
    new_res_x = full_interval_amount_x * ( interval_x - skip_pixels_x ) + px_in_last_interval_x
    delta_x = new_res_x - des_resolution_x
    skip_pixels_x_list.append( skip_pixels_x )
    interval_x_list.append( interval_x )
    res_x_list.append( new_res_x )
    delta_x_list.append( abs( delta_x ) )

val_x, idx_x = min( ( val_x, idx_x ) for ( idx_x, val_x ) in enumerate( delta_x_list ) )
print( "Skip %d" % skip_pixels_x_list[idx_x] )
print( "Interval %d" % interval_x_list[idx_x] )
print( "Resolution %d" % res_x_list[idx_x] )
print( "Delta %d" % delta_x_list[idx_x] )

      
skip_pixels_y_list = []
interval_y_list = []
res_y_list = []
delta_y_list = []

for skip_pixels_y in range( 1, 100 ):
  for interval_y in range( 2, 100 ):
    if( interval_y <= skip_pixels_y ):
      continue
    interval_amount_y = math.ceil( orig_resolution_y / float( interval_y ) )
    full_interval_amount_y = math.floor( orig_resolution_y / float( interval_y ) )
    if( full_interval_amount_y != interval_amount_y ):
      px_in_last_interval_y = orig_resolution_y  - full_interval_amount_y * interval_y
      if( px_in_last_interval_y > ( interval_y - skip_pixels_y ) ):
        px_in_last_interval_y = interval_y - skip_pixels_y
    else:
      px_in_last_interval_y = 0
    new_res_y = full_interval_amount_y * ( interval_y - skip_pixels_y ) + px_in_last_interval_y
    delta_y = new_res_y - des_resolution_y
    skip_pixels_y_list.append( skip_pixels_y )
    interval_y_list.append( interval_y )
    res_y_list.append( new_res_y )
    delta_y_list.append( abs( delta_y ) )

val_y, idx_y = min( ( val_y, idx_y ) for ( idx_y, val_y ) in enumerate( delta_y_list ) )
print( "Skip %d" % skip_pixels_y_list[idx_y] )
print( "Interval %d" % interval_y_list[idx_y] )
print( "Resolution %d" % res_y_list[idx_y] )
print( "Delta %d" % delta_y_list[idx_y] )
