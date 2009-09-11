#!/usr/bin/env python
# -*- coding: utf-8 -*-

# (c) Krzysztof Walo, 2007
# Skrypt zmieniający ustawienia na kartach z chipsetem rt61 za pomocą iwpriv

import sys
import os
from optparse import OptionParser


def get_option_parser():
	p = OptionParser(usage='usage: %prog [options] netspec')
	p.add_option('-a', '--ip', action='store', type='string', dest='addr')
	p.add_option('-g', '--gateway', action='store', type='string',
				 dest='gateway')
	p.add_option('-i', '--iface', action='store', type='string', dest='iface')
	p.add_option('-m', '--netmask', action='store', type='string',
				 dest='netmask')
	p.add_option('-n', '--simulate', action='store_true', dest='simulate')
	p.add_option('-l', '--list-locations', action='store_true',
				 	dest='list_locations')
	p.add_option('-s', '--show-location', action='store', type='string',
				 dest='show')
	p.set_defaults(iface='ra0', addr=None, gateway=None,
				   netmask='255.255.255.0', simulate=False,
				   list_locations=False)
	
	return p

def get_location_file(location):
	import os
	fname = '/etc/Wireless/Locations/%s' % (location)
	if not os.path.exists(fname):
		print >> sys.stderr, "Location file: %s doesn't exist" % (fname)
		sys.exit(1)
	return fname
	
def get_location_contents(fd):
	lst = []
	for l in f:
		l = l.strip()
		if l != '' and l[0] != '#':
			lst.append(l)
	return lst

def sh(command, fail_exit=True):
	status = os.system(command)
	if status != 0 and fail_exit:
		print >> sys.stderr, "Command: %s failed" % (repr(command))
		sys.exit(status)
		
	return status

if __name__ == '__main__':
	p = get_option_parser()
	options, args = p.parse_args()

	if options.list_locations:
		try:
			for l in os.listdir('/etc/Wireless/Locations'):
				print l
		except OSError, e:
			print >> sys.stderr, "Unable to read location directory: %s" % \
				(str(e))
			sys.exit(1)
		finally:
			sys.exit()
	elif options.show:
		try:
			fname = get_location_file(options.show)
			f = file(fname, 'r')
		except Exception, e:
			print >> sys.stderr, 'Unable to open file "%s": %s' % \
				  (fname, str(e))
			sys.exit(1)
		for i in get_location_contents(f):
			print i
		f.close()
		sys.exit()

	try:
		fname = args[0]
	except IndexError, e:
		print >> sys.stderr, """Must provide network location.
To see available locations, run 'wifi.py --list-locations'
To add new location, create a file in /etc/Wireless/Locations"""
		sys.exit(1)

	if options.simulate:
		sh = lambda a: sys.stdout.write(a + '\n')
	elif os.getuid() != 0:
		print >> sys.stderr, 'You must be root to change wireless settings'
		sys.exit(1)

	fname = get_location_file(args[0])

	try:
		f = file(fname, 'r')
	except Exception, e:
		print >> sys.stderr, "Error opening file '%s': %s" % (fname, str(e))
		sys.exit(1)

	sh('/sbin/ifconfig %s up' % (options.iface))

	for i in get_location_contents(f):
		sh('/sbin/iwpriv %s set %s' % (options.iface, i))
	f.close()
	
	if options.addr:
		cmd = '/sbin/ifconfig %s %s' % (options.iface, options.addr)
		if options.netmask:
			cmd += ' netmask %s' % (options.netmask)
		sh(cmd)
		if options.gateway:
			sh('/sbin/route add default gw %s' % (options.gateway))
	else:
		sh('/sbin/dhclient %s' % (options.iface))
