#!/bin/sh
# \
exec tclsh "$0" "$@"

#       Converter for MaxMind CSV database to binary, for xt_geoip
#       Copyright Andrew S. Johnson, 2015-2019

package require ip

set ginfo "GeoLite2-Country-Locations-en.csv"
set geocsv "GeoLite2-Country-Blocks-IPv4.csv"

if { [catch {set geoid [open $ginfo r]} geoErr] } {
	puts "Failed to open input file '$ginfo': $geoErr"
	exit
}

if { [catch {set csvid [open $geocsv r]} geoErr] } {
	puts "Failed to open input file '$geocsv': $geoErr"
	exit
}

# initialize arrays for little and big endian data
# arrays are strings of binary 32-bit integer pairs of begin and end IP ranges
# arrays are indexed by geoname_id
array set gid {}
array set leip {}
array set beip {}

set stime [clock milliseconds]

while { ![eof $geoid] } {
	if { [catch {gets $geoid gdata} geoErr] } {
		puts "Read failed for input file '$ginfo': $geoErr"
		catch {close $geoid}
		exit
	}

# split string into list on commas
	set gcsv [split $gdata ","]
	set gccid [lindex $gcsv 0]
	if {[string is integer -strict "$gccid"]} {
		set gid($gccid) $gcsv
	}
}
catch {close $cfoid}
parray gid


while { ![eof $csvid] } {
	if { [catch {gets $csvid liprange} geoErr] } {
		puts "Read failed for input file '$geocsv': $geoErr"
		catch {close $csvid}
		exit
	}

# split string into list on commas
	set lliprange [split $liprange ","]

# country code is list item 1
	set ipcc [lindex $lliprange 1]

	if {[string is integer $ipcc] && $ipcc > 0} {

# IP cidr is list item 0
		set ipcidr [lindex $lliprange 0]
		set ipnet [lindex [split $ipcidr /] 0]
		set ipbcast [ip::broadcastAddress $ipcidr]
#		puts "$ipcc $ipnet $ipbcast"
		set ippair [list [ip::toInteger $ipnet] [ip::toInteger $ipbcast]]
#		puts "$ipcc $ippair"

# append data to existing string as little endian integers
		append leip($ipcc) [binary format i2 $ippair]

# append data to existing string as big endian integers
#		append beip($ipcc) [binary format I2 $ippair]
	}
}
catch {close $csvid}
#parray leip


set rtime [clock milliseconds]
puts "CSV read time: [expr $rtime - $stime] ms"

# loop through each country
set cctoken [array startsearch leip]
while {[array anymore leip $cctoken]} {
	set cckey [array nextelement leip $cctoken]
	if {[info exists gid($cckey)]} {
		set ccode [lindex $gid($cckey) 4]
		if {[string is alnum -strict "$ccode"]} {

# write little endian addresses to file
			if { [catch {set leccid [open "LE/$ccode.iv4" {WRONLY CREAT TRUNC BINARY}]} outErr] } {
				puts "Failed to open output file 'LE/$ccode.iv4': $outErr"
				exit
			} else {
				puts -nonewline $leccid $leip($cckey)
				close $leccid
			}
		} else {
			puts "ccode <$ccode> not found"
		}
	} else {
		puts "cckey <$cckey> not found"
	}

# write big endian addresses to file
#	if { [catch {set beccid [open "BE/$ccode.iv4" {WRONLY CREAT TRUNC BINARY}]} outErr] } {
#		puts "Failed to open output file 'BE/$ccode.iv4': $outErr"
#		exit
#	} else {
#		puts -nonewline $beccid $beip($cckey)
#		close $beccid
#	}
}
array donesearch leip $cctoken

set wtime [clock milliseconds]
puts "iv4 write time: [expr $wtime - $rtime] ms"

exit
