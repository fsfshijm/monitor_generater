#!/usr/local/bin/python2.7
# coding: utf-8

import sys
reload(sys)
sys.setdefaultencoding('utf-8')
import os
from os import path
import ConfigParser
import urllib2
from urllib import unquote
from datetime import date, timedelta, datetime
import time
from collections import defaultdict
from xxxxxxxx_pyutils.email_tools import SmtpEmailTool
import logging
import logging.config
import subprocess
import string
import pdb
import re

basedir = path.realpath(path.join(path.dirname(__file__), '..'))
os.chdir(basedir)
sys.path.append(path.join(basedir, 'lib'))
sys.path.append(basedir+'/conf')

#pdb.set_trace()

import monitor_util as MNU

class FileScaner:
	
	def __init__(self, configFile):
		self.logger = logging.getLogger('xxxxxxxx.fileScaner.monitor')
		self.logger.info('FileScaner inited')
		self.config = ConfigParser.ConfigParser()
		self.config.read(configFile)
		self.formatData()

	def formatData(self):
		self.logger.info('formatData start ...')
		self.servers = self.config.get('sys','servers').split(',')
		self.fileDir = self.config.get('sys','fileDir')
		self.fileRegex = self.config.get('sys','fileRegex')
		self.hoursAgo = self.config.getint('sys','hoursAgo')
		self.type = self.config.getint('sys','type')
		self.objectList = self.config.get('sys','objectList').split(',')
		self.preRegex = self.config.get('sys','PrePrcessRegex')
		self.tempFileName = basedir + '/data.tmp'

		self.totalData = {}
		for object in self.objectList:
			options = self.config.options(object)
			self.totalData[object] = {'objKeys':[], 'data':{}}
			for item in options:
				self.setKeys(object, item)

		self.logger.info(self.totalData)
		stamp = os.environ.get("DOMINO_STAMP", None)
		if not stamp:
			localtime = datetime.today() - timedelta(hours=self.hoursAgo)
		else: 
			localtime = datetime.strptime(stamp, "%Y-%m-%d %H:%M:%S") - timedelta(hours=self.hoursAgo)
		self.fileTime = localtime.strftime("%Y%m%d%H")
		self.dt = localtime.strftime("%Y-%m-%d")
		self.hr = int(localtime.strftime("%H"))
		self.logger.info('时间:' + self.fileTime)
		self.logger.info('formatData finish ...')


	def setKeys(self, object, item):
		if self.type in [1, 2]:
			key = item
			self.totalData[object]['objKeys'].append(key)
			self.totalData[object]['data'][key] = 0
		else: #自己扩展
			keys = self.config.get(object, item).split(',')
			for key in keys:
				self.totalData[object]['objKeys'].append(key)
				self.totalData[object]['data'][key] = 0
				

	def scaner(self):
		self.logger.info('scaner start ...')
		if (self.type != 1) and (self.servers != ["localhost"]):
			print 'unsupported  type=%s, servers=%s ' % (self.type, string.join(self.servers, ','))
			return

		for server in self.servers:
			if self.type == 1:
				cmd = ""
				if server == "localhost":
				    cmd = """wc -l %s/%s | awk 'END{print echo $1}'""" % (self.fileDir, self.fileRegex.replace('fileScanerTime', self.fileTime))
				else:
				    cmd = """ssh monitor@%s 'wc -l %s/%s' | awk 'END{print echo $1}'""" % (server, self.fileDir, self.fileRegex.replace('fileScanerTime', self.fileTime))

				obj = self.objectList[0]
				key = self.totalData[obj]['objKeys'][0]
				self.totalData[obj]['data'][key] += int(subprocess.check_output(cmd, shell=True))
			else :
 				cmd = """find %s -name "%s" """ % (self.fileDir, self.fileRegex.replace('fileScanerTime', self.fileTime))
 				file_str = subprocess.check_output(cmd, shell=True)
 				file_list = file_str.split(' ')[0].split('\n')
 				file_list = [e for e in file_list if e != '']
				for file in file_list:
					if self.preRegex != '' and self.preRegex != None:
						cmd = "grep %s %s > %s" % (self.preRegex, file, self.tempFileName)
						self.logger.info("preProcess:" + cmd)
						os.system(cmd)
						f = open(self.tempFileName)
					#如果没有预处理，则直接读文件
					else :
						f = open(file)            
					line = f.readline()             
					while line:
						line = f.readline()
						if self.type == 2:
							self.commonScaner(line)
						else:
							self.specialScaner(line)
					
					f.close()
					

		self.logger.info('scaner finish ...')

	def commonScaner(self, line):
		for obj in self.totalData:
			for key in self.totalData[obj]['objKeys']:
				regex = self.config.get(obj, key)
				if re.search(regex, line):
					self.totalData[obj]['data'][key] += 1
			
	
	def specialScaner(self, line):
		"""
		do some special
		"""
		if not re.search('type=state_report', line):
			return
		line = unquote(line)
		line = line.split('&')
		expect = {}
		for item in line:
			if re.search('data=', item):
				expect = eval(item.split('=')[1])
				break	
		for obj in self.totalData:
			for key in self.totalData[obj]['objKeys']:
				self.totalData[obj]['data'][key] += expect.get(key, 0)


	def sendData(self):
		for key, value in self.totalData.iteritems():
			MNU.insert_reports_data(value['data'], key, self.dt, self.hr)

	def sendReport(self):
		print 'send_report ...' 
		html = ""
		html += '<h2><FileScaner数据监控 %s></h2>' % self.fileTime
		html += '<h3><说明：非‘丢失率’列记录的是各个环节这个小时总的log数，丢失率 = (前一个环节log数 - 当前环节log数) / 前一个环节log数 > </h3>'
		html += '<hr/>'
		html += '<hr/>'
		html += '<style> .list {padding: 0px; margin: 0px; border-spacing:0px; border-collapse: collapse; width: 100%;border:1px solid #d2d6d9;}.list th {background-color: #8EB31A; color: #fff; font-size:14px; font-weight: bold; line-height: 20px; padding-top: 4px;border:1px solid #d2d6d9;} .list td {border-top: 1px solid #d2d6d9; padding-top: 1x; font-size: 12px; color: #000;height: 20px; text-align: center;border-right:1px solid #8eb31a;} .list .odd td {background-color: #FFF;} .list .even td {background-color: #F0F9D6;}</style>'

		for object, value in self.totalData.iteritems():
			html += '<h3>%s</h3>' % object
			html += '<table class="list" border="1" align="center" style="width:800px;">'

			html += '<tr>'
			html += '<th>key</th><th>数量</th>'
			html += '</tr>'
			for key1, value1 in value['data'].iteritems():
				html += '<tr>'
				html += '<td>%s</td><td>%s</td>' % (key1, value1)
				html += '</tr>'
			html += '</table>'

		emailTools = SmtpEmailTool(
				self.config.get('email','server'),
				self.config.get('email','user'),
				self.config.get('email','password')
		)
		mail_to = self.config.get('email','toAddr').split(',')
		subject = self.config.get('email','subject')
		emailTools.sendEmail(mail_to, subject, html.encode('utf8'))


	def run(self):
		self.scaner()
		self.sendData()
		if self.config.getint('email', 'sendEmail') == 1:
			self.sendReport()
		


if __name__ == '__main__':
	loggingConfigFile = path.join(basedir, 'conf/logging.conf')
	logging.config.fileConfig(loggingConfigFile)
	configFile = path.join(basedir, 'conf/fileScaner.cfg')
	o = FileScaner(configFile)
	o.run()

