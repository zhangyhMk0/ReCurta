from xmlrpclib import ServerProxy
from os.path import isfile
wikidoturl = file('wikidoturl', 'r').read()
s = ServerProxy(wikidoturl)
import time
import yaml

references = yaml.load(file('crossref.yaml'))
referenced = dict()
for parent, children in references.items():
	for child in children:
		if child not in referenced:
			referenced[child] = []
		if parent not in referenced[child]:
			referenced[child].append(parent)

bom = []
names = dict()

for line in file('bom.txt'):
	num, name, quantity = [x.strip() for x in line.split('||')][1:-1]
	num = int(num.split(' ')[0][3:-3])
	bom.append((num, name, int(quantity)))
	names[num] = name

for num, name, quantity in bom:
	time.sleep(.25)
	print 'Creating', num

	body = '[[image Curta_1_%i.jpg size="medium"]]\n\n' % num
	if num in referenced:
		body += '**Referenced by**:\n'
		for elem in referenced[num]:
			body += '* [[[%i]]] -- %s\n' % (elem, names[elem] if elem in names else 'Unknown part')
		body += '\n'
	if num in references:
		cref = []
		body += '**References**:\n'
		for elem in references[num]:
			if elem not in cref:
				cref.append(elem)
				body += '* [[[%i]]] -- %s\n' % (elem, names[elem] if elem in names else 'Unknown part')
		body += '\n'
	
	s.pages.save_one(dict(
		site='curtawiki', page=str(num), 
		title='%i -- %s' % (num, name.lstrip('!')), 
		content=body, 
		save_mode='create_or_update'
	))

	bfn = 'Curta_1_%i.jpg' % num
	fn = '/home/daeken/demoseen/curta/Curta_1_%i.jpg' % num
	if isfile(fn) and bfn not in s.files.select(dict(site='curtawiki', page=str(num))):
		time.sleep(1)
		print 'Uploading', bfn
		data = file(fn, 'rb').read()
		s.files.save_one(dict(
			site='curtawiki', page=str(num), 
			file=bfn,
			content=data.encode('base64').replace('\n', ''), 
			save_mode='create', 
		))