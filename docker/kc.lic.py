#!/usr/bin/env python

from __future__ import with_statement
from __future__ import print_function
import sys
try:
  from urllib.error import HTTPError
except ImportError:
  from urllib2 import HTTPError
try:
  from urllib.parse import urlencode
except ImportError:
  from urllib import urlencode
try:
  from urllib.request import Request, urlopen
except ImportError:
  from urllib2 import Request, urlopen
try:
  input = raw_input
except NameError:
  pass
from optparse import OptionParser
import os
import platform
import base64

qhome = os.getenv('QHOME')
if not qhome or not os.path.isdir(qhome):
  print('QHOME env is not set to a directory', file=sys.stderr)
  sys.exit(2)

qlic = os.getenv('QLIC', qhome)
if not os.path.isdir(qlic):
  print('QLIC env is not set to a directory for storing the license', file=sys.stderr)
  sys.exit(2)

qarch = {'Linux':'l64', 'Darwin':'m64', 'Windows':'w64'}
plat = platform.system()
if not plat in qarch:
  print("unknown platform '" + plat + "'", file=sys.stderr)
  sys.exit(2)

if plat == 'Windows':
	qbin = 'q.exe'
else:
	qbin = 'q'
qpath = os.path.join(qhome, qarch[plat], qbin)
if not os.path.isfile(qpath):
  print("missing q binary at '{}'".format(qpath), file=sys.stderr)
  sys.exit(2)

url = os.getenv('KDB_LICENSE_URL', 'https://l.kx.com/l')

parser = OptionParser()
parser.add_option('-a', '--agree', dest='agree', action='store_true', help='agree to terms of license agreement', default=os.getenv('KDB_LICENSE_AGREE'))
parser.add_option('-c', '--company', dest='company', help='company name (optional)', default=os.getenv('COMPANY'))
parser.add_option('-n', '--name', dest='name', help='name', default=os.getenv('NAME'))
parser.add_option('-e', '--email', dest='email', help='email address', default=os.getenv('EMAIL'))
parser.add_option('-l', '--license-number', dest='num', help='license number', default=os.getenv('KDB_LICENSE_NUMBER'))
(options, args) = parser.parse_args()

def license_agreement ():
  print('''\
kdb+ on demand - Personal Edition

kdb+ on demand 64 bit personal edition is for personal, non-commercial use. It may be used freely on up to 2 computers, and up to a maximum of 16 cores per computer, but is not licensed for use on any cloud, only personal computers. It may not be used for any commercial purposes, please read the license carefully.

kdb+ on demand requires an always on internet connection to operate. Whilst the software is all installed on your local environment, kdb+ on demand sends 'I'm alive' packets out to our servers on a regular basis. These packets form the basis of billing for commercial users. kdb+ on demand will exit if it is unable to send these packets. Details on the information sent in these packets are fully detailed in the license below. No other information is sent. No information received by Kx will ever be shared with any third party, and will not be used for any purposes other than license management.

If you are interested in using 64 bit on demand in a commercial environment, then please email ondemand@kx.com for further details.

----- BEGIN LICENSE AGREEMENT -----
On Demand Kdb+ Software License Agreement for non commercial use

CAREFULLY READ THE FOLLOWING TERMS AND CONDITIONS. BY DOWNLOADING THE KDB+ SOFTWARE, YOU ARE AGREEING ON YOUR OWN BEHALF AND IN THE EVENT AN ENTITY IS LICENSING THE PRODUCT ("ENTITY") THAT YOU BOTH SHALL BE BOUND BY THESE TERMS AND CONDITIONS (BOTH OF WHICH WILL BE DEEMED AN "END USER"). YOU ARE AGREEING THAT AS AN END USER YOU ARE BECOMING A PARTY TO THIS ON DEMAND KDB+ SOFTWARE LICENSE AGREEMENT FOR NON COMMERCIAL USE ("AGREEMENT") AND THAT YOU HAVE THE AUTHORITY TO BIND YOURSELF TO LICENSE THE PRODUCT AS AN END USER AND IF APPLICABLE THE ENTITY. IF YOU OR THE ENTITY DOES NOT AGREE TO THESE TERMS AND CONDITIONS, DO NOT DOWNLOAD THE SOFTWARE.

This Agreement is made between Kx Systems, Inc. ("Kx") and the End User with respect to the on demand version of Kx's Kdb+ Software, any updates and/or any documentation provided to you by Kx which is provided strictly for non commercial purposes (jointly, the "Kdb+ On Demand Software"). You agree to use the Kdb+ On Demand Software under the terms and conditions set forth below which shall be subject to change from time to time.

1. LICENSE GRANTS

1.1 Grant of License. Kx hereby grants End User a non-transferable, non-exclusive license, without right of sublicense, to install the Kdb+ On Demand Software on the hard disk or other permanent storage media of a total of two (2) of End Users computers in executable code form and to use the Kdb+ On Demand Software solely for personal, non-commercial use only. You may use the Kdb+ On Demand Software for personal, internal use, but you are not permitted under any circumstances to use the Kdb+ On Demand Software for (a) production, testing, disaster recovery or commercial use by you or any other person or entity (b) for any benefit of a company, for profit entity, government entity or educational institution (c) in any way connected to a revenue generating purpose (d) research or development of a product or application which may be used now or in the future for a commercial purpose (e) existing clients of Kx who have licensed the Kdb+ Software prior to the date of this Agreement. The number of cores on which the Kdb+ On Demand Software is running may not exceed a total of sixteen (16) cores per computer.

1.2 Kdb+ On Demand Software Use Restrictions. End User may not: (a) modify the Kdb+ On Demand Software or create derivative works, (b) sell, lease, license or distribute the Kdb+ On Demand Software to any third party, (c) attempt to decompile or reverse engineer the Kdb+ On Demand Software, or (d) copy the Kdb+ On Demand Software except for purposes of installing and executing it on a single computer. For the avoidance of doubt, End User shall not without Kx's permission be permitted to use the Kdb+ On Demand Software on a third party cloud provider's computer.

1.3 Kdb+ On Demand Software Performance. End User shall not distribute or otherwise make available to any third party any report regarding the performance of the Kdb+ On Demand Software, Kdb+ On Demand Software benchmarks or any information from such a report unless End User receives the express, prior written consent of Kx to disseminate such report or information.

1.4 Disabling Features. End User understands that the Kdb+ On Demand Software contains a feature which will automatically cause the Kdb+ On Demand Software to time-out six (6) months from the date of installation of the Kdb+ On Demand Software or such other date which Kx at its discretion identifies. Kx may at its discretion from time to time agree to extend use of the Kdb+ On Demand Software for a further six (6) months or such other period which Kx at its discretion identifies.

1.5 Kdb+ On Demand Software Reporting. The Kdb+ On Demand Software periodically communicates (approximately once per minute) with a license manager application running on a Kx server. The Kdb+ On Demand Software sends usage information to the license manager software, which confirms that the End User is licensed to use the Kdb+ On Demand Software. If the license manager software determines that the Kdb+ On Demand Software use is not licensed, the license manager software will halt the Kdb+ On Demand Software.

(a) Information Reported. The following Kdb+ On Demand Software variables are reported by the Kdb+ On Demand Software to the license manager software (which are upon notice, subject to change) :

    .z.p
    .z.a
    .z.h
    .z.o
    .z.i
    .z.u
    .z.K
    .z.k
    \s
    \p
    .z.l
    cpu mask as in sched_getaffinity(2)
    cpu usage as in getrusage(2)

Information about the variables is available at https://code.kx.com.

(b) Information Access. The information reported by the Kdb+ On Demand Software to the Kx license manager is available only to authorized personnel at Kx or its affiliates. The information is not shared with other third parties.

(c) Non-Interference. End User agrees that it will not attempt to interfere, delay or in any way restrict the Kdb+ On Demand Software reporting to the Kx server.

1.6 Intellectual Property Ownership Rights. End User acknowledges and agrees that Kx owns all rights, title and interest in the Kdb+ On Demand Software and in all of Kx's patents, trademarks, trade names, inventions, copyrights, know-how and trade secrets relating to the design, manufacture and operation of the Kdb+ On Demand Software. The use by End User of such proprietary rights is authorized only for the purposes set forth herein, and upon termination of this Agreement for any reason, such authorization will cease. End User acknowledges that the Kdb+ On Demand Software is proprietary and contains confidential and valuable trade secrets of Kx, which End User agrees to safeguard as provided for under section 6, Confidential Information, below.

2. NO SUPPORT OR MAINTENANCE. The Kdb+ On Demand Software is licensed to End User without any support (consulting services) or maintenance (error corrections).

3. FEES. The Kdb+ On Demand Software is licensed to End User without charge.

4. NO WARRANTY. THE KDB+ ON DEMAND SOFTWARE IS PROVIDED "AS IS." KX EXPRESSLY DISCLAIMS AND NEGATES ALL WARRANTIES FOR THE KDB+ ON DEMAND SOFTWARE, WHETHER EXPRESSED, IMPLIED, STATUTORY OR OTHERWISE, AND KX SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NONINFRINGEMENT OF INTELLECTUAL PROPERTY OR OTHER VIOLATION OF RIGHTS. KX DOES NOT WARRANT THAT THE KDB+ ON DEMAND SOFTWARE WILL MEET END USER REQUIREMENTS OR THAT THE OPERATION OF THE KDB+ ON DEMAND SOFTWARE WILL BE UNINTERRUPTED OR ERROR FREE.

5. LIMITATION OF LIABILITY. KX SHALL NOT BE LIABLE FOR ANY DAMAGES, AND IN PARTICULAR SHALL NOT BE LIABLE FOR ANY SPECIAL, INCIDENTAL, CONSEQUENTIAL, INDIRECT OR OTHER SIMILAR DAMAGES, IN CONNECTION WITH OR ARISING OUT OF THE USE OF OR INABILITY TO USE THE KDB+ ON DEMAND SOFTWARE, EVEN IF KX HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. SUCH DAMAGES INCLUDE, BUT ARE NOT LIMITED TO, LOSS OF PROFITS, REVENUE OR BUSINESS INFORMATION.

6. CONFIDENTIAL INFORMATION. As used in this Agreement, the term "Confidential Information" means (a) information disclosed in writing by one party to the other and marked confidential, (b) information disclosed orally by one party to the other and summarized in writing by the discloser and marked confidential, and (c) the Licensed Software and Documentation. Each party agrees that during the term of this Agreement and for a period of five (5) years thereafter, it will treat as confidential all Confidential Information of the other party, will not use such Confidential Information except as expressly set forth herein or otherwise authorized in writing, will implement reasonable procedures to prohibit the disclosure, duplication, misuse or removal of the other party's Confidential Information and will not disclose such Confidential Information to any third party except as may be necessary and required in connection with the rights and obligations of such party under this Agreement, and subject to confidentiality obligations at least as protective as those set forth herein. Without limiting the foregoing, each party will use at least the same procedures and degree of care that it uses to prevent the disclosure of its own confidential information of like importance to prevent the disclosure of Confidential Information disclosed to it by the other party under this Agreement, but in no event less than reasonable care.

7. TERM AND TERMINATION OF AGREEMENT. This Agreement is for the period that the Kdb+ On Demand Software is set to function when delivered to the End User, unless Kx provides the End User with subsequent copies with a later expiration, in which case this Agreement is extended for the additional period. Notwithstanding the foregoing, this Agreement shall automatically terminate immediately upon Kx's written notice. Kx may also at its discretion terminate End User's access to the Kdb+ On Demand Software at any time. Upon termination of this Agreement or at any time upon Kx's written request, End User shall destroy all copies of the Kdb+ On Demand Software in his possession.

8. GENERAL
This is the only Agreement between End User and Kx relating to the Kdb+ On Demand Software. This Agreement shall be governed by California law, except as to copyright matters covered by Federal law. This Agreement is deemed entered into at Palo Alto, California by both parties. Any dispute related to this Agreement shall be resolved only in the California State Courts or Federal Courts located in Santa Clara County, California, and End User hereby waives any objections to venue in those courts. Should any provision of this Agreement be declared unenforceable in any jurisdiction, then such provision shall be deemed to be severed from this Agreement and shall not affect the remainder hereof. End User agrees and certifies that the Kdb+ On Demand Software shall not be shipped, transferred or exported, directly or indirectly, into any country prohibited by the United States Export Administration Act, and the regulations thereunder, or will the Kdb+ On Demand Software be used for any purpose prohibited by the same. The Kdb+ On Demand Software may from time to time be subject to export control and economic sanctions laws, regulations and requirements and to import laws, regulations and requirements of certain foreign governments. End User shall not, and shall not allow any third party to, export or allow the re-export or re-transfer of any part of the Kdb+ On Demand Software in violation of any export or import laws, regulations or requirements of any government, foreign agency or authority. The provisions of section 1.4 ("Intellectual Property Ownership Rights"), section 4 ("No Warranty"), section 5 ("Limitation of Liability"), section 6 ("Confidential Information"), section 7 ("Term and Termination") and Section 8 ("General") shall survive the termination of this Agreement for any reason. All other rights and obligations of the parties shall cease upon termination of this Agreement.
----- END LICENSE AGREEMENT -----
''')

def prompt(prompt):
  if not sys.stdin.isatty():
    print('headless detected, please read https://github.com/KxSystems/embedPy#headless', file=sys.stderr)
    sys.exit(1)
  return input(prompt)

def fetch_options():
  global options

  if not options.agree:
    license_agreement()
    options.agree = prompt('I agree to the terms of the license agreement for kdb+ on demand Personal Edition (N/y): ')
    print()
  if options.agree.lower()[0:1] != 'y' and options.agree[0:1] != '1':
    print('not agreed to license, aborting', file=sys.stderr)
    sys.exit(0)

  if not options.company and not options.name and not options.email:
    options.company = prompt('If applicable please provide your company name (press enter for none): ')
    if len(options.company) == 0:
      options.company = None

  while not options.name:
    options.name = prompt('Please provide your name: ')
    if len(options.name) == 0:
      print('name cannot be zero length', file=sys.stderr)
      options.name = None

  while not options.email:
    options.email = prompt('Please provide your email (requires validation): ')
    if len(options.email) == 0:
      print('email cannot be zero length', file=sys.stderr)
      options.email = None

def license():
  request = Request(url, urlencode({
    't': 'email',
    'v': options.email,
    'num': options.num,
    'name': options.name,
    'company': options.company,
  }).encode())
  try:
    response = urlopen(request)
  except HTTPError as e:
    e.read()
    response = e

  if response.code >= 400:
    print('failed with HTTP status code ' + str(response.code) + ': ', file=sys.stderr, end='')
    if response.code == 400:
      print('likely invalid email', file=sys.stderr)
    elif response.code == 429:
      print('throttled, please try again later', file=sys.stderr)
    else:
      print('if this continues, please contact ondemand@kx.com for assistance', file=sys.stderr)
    sys.exit(1)

  with open(os.path.join(qlic, 'kc.lic'), 'wb') as file:
    file.write(response.read())

for el, ln in [('QLIC_K4', 'k4.lic'), ('QLIC_KC', 'kc.lic')]:
  lic = os.getenv(el)
  if lic:
    with open(os.path.join(qlic, ln), 'wb') as file:
      file.write(base64.b64decode(lic))
    break
else:
  for p in [qlic, qhome, '.']:
    if os.path.isfile(os.path.join(p, 'k4.lic')):
      break
    if os.path.isfile(os.path.join(p, 'kc.lic')):
      break
  else:
    fetch_options()
    license()

if os.path.basename(sys.argv[0].lower()) == qbin:
  retcode = os.execv(qpath, [ qbin ] + args)
  sys.exit(retcode)
