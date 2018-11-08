#!/usr/bin/python

import sys, string, shutil, os, os.path, re, subprocess
from datetime import datetime

#log vars:
logFile = 'backupi.log'
debug = True

#code vars:
backupCase = ''
shScriptFile = ''
# configFile = 'backupi.config'
collectionFile = 'backupi.collection'

remoteDir = []
localDir = []
mount = []


# LOG function
def log(logStr):
	timeStr = str(datetime.now()) 
	print '[log] ' + logStr
	with open(logFile, 'a') as myLog:
		myLog.write(timeStr + ' [log] ' + logStr + '\n')
	return;

# DEBUG function
def debug(dbgStr):
	if debug:
		print '[debug] ' + dbgStr
	return;

# ERROR function
def err(errStr):
	timeStr = str(datetime.now()) 
	print '=============================================================================='
	print '[ERROR]: ' + errStr
	print 'exiting code...'
	print '=============================================================================='
	with open(logFile, 'a') as myLog:
		myLog.write('============================================================\n')
		myLog.write(timeStr + ' [ERROR] ' + errStr +'\n')	
		myLog.write('============================================================\n')
	if (errStr != 'Another backupi process is running. Please wait or check for errors.\nNo backup started.'):
		os.remove(pidFile)
		debug('deleted PID file and exiting.')
	sys.exit(1)
	return;

# CHECKDIRECTORIES function
def checkdirectories(dirs):
	for ldir in dirs:
		cmd = 'df | grep ' + ldir
		debug(' checking output of cmd: ' + cmd)
		proc=subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, )
		output=proc.communicate()[0]
		debug('  > ' + output)
		matches = re.findall(ldir,output)
		if (len(matches) > 0):
			err('Directory ' + ldir + ' is yet mounted and should not be!')
	return;

# CHECKDISKSTATUS functions
def checkdiskstatus_1():
	cmd = 'blkid -o list | grep crypto_LUKS | grep "(not mounted)" | grep /dev/sda1'
	debug(' Disk check 1.\n  checking output of cmd: ' + cmd)
	proc=subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, )
	output=proc.communicate()[0]
	matches = re.findall('/dev/sda1',output)
	debug('   found ' + str(len(matches)) + ' occurrences.')
	if (len(matches) == 1):
		debug("  Check 1 OK.")
	else:
		err("Disk check 1 failed.")
	return;
def checkdiskstatus_2():
	cmd = 'blkid -o list | grep /dev/sda1'
	debug(' Disk check 2.\n  checking output of cmd: ' + cmd)
	proc=subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, )
	output=proc.communicate()[0]
	matches = re.findall('/dev/sda1',output)
	debug('   found ' + str(len(matches)) + ' occurrences.')
	if (len(matches) == 1):
		debug("  Check 2 OK.")
	else:
		err("Disk check 2 failed.")
	return;
def checkdiskstatus_3():
	cmd = 'df | grep sda1'
	debug(' Disk check 3.\n  checking output of cmd: ' + cmd)
	proc=subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, )
	output=proc.communicate()[0]
	matches = re.findall('sda1',output)
	debug('   found ' + str(len(matches)) + ' occurrences.')
	if (len(matches) == 0):
		debug("  Check 3 OK.")
	else:
		err("Disk check 3 failed.")
	return;

# ---------- START CODE ---------- #

#check existing process and creating PID:
pidFile = '.backupi.pid'
if os.path.isfile(pidFile):
	err('Another backupi process is running. Please wait or check for errors.\nNo backup started.')
else:
	open(pidFile, 'a').close()
	debug('created PID file')

# read arguments and check
if (len(sys.argv) == 2):
	backupCase = sys.argv[1]
	log('start checking for backup: ' + backupCase)
	shScriptFile = 'backup_' + backupCase + '.sh'
	if os.path.isfile(shScriptFile):
		debug('shScriptFile ' + shScriptFile + '... check ok.')
	else:
		err(shScriptFile + ' not found in thit directory!') 
#	if os.path.isfile(configFile):
#		debug('configFile ' + configFile + '... check ok.')
#	else:
#		err(configFile + ' not found in thit directory!') 
	if os.path.isfile(collectionFile):
		debug('collectionFile ' + collectionFile + '... check ok.')
	else:
		err(collectionFile + ' not found in thit directory!') 
else:
	err('number of arguments not valid')


# check backup disk status
checkdiskstatus_1()
checkdiskstatus_2()
checkdiskstatus_3()

# read collection file
with open(collectionFile, 'r') as f:
	pattern = '^' + backupCase
	for line in f.readlines():
		if re.match(pattern, line) :
			values = re.split(r'\t', line)
			#TODO: add values string verification for preventing errors.
			remoteDir.append(values[1])
			localDir.append(values[2])
			mount.append(values[3])

# check directories
checkdirectories(localDir)

# execute sh script
debug('- calling EDBackuPi sh script ----------------------------')
# subprocess.call('./' + shScriptFile)
debug('------------------------------------------------------------')

# check umounts
checkdirectories(localDir)
checkdiskstatus_1()
checkdiskstatus_2()
checkdiskstatus_3()

# delete PID
os.remove(pidFile)
debug('deleted PID file')
log('EDBackuPi successfully completed ' + backupCase + ' backup!')
