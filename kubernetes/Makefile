
# old style che non va mai ma qui pare andare...
#https://aj-alphabet.palladi.us/
#http://aj-alphabet.palladi.us/
##

status:
	# Questo funge solo per me - ma lo OSSero' presto e metto in un medium article.
	ks up -k .

up:
#	../kubectl apply -f .
	ks up -k .
	


# nota che prod va a modo suo con NodePort e con la brittleconfig
# devo solo settare dev...
fix-ips:
	# from palladius/sakura: funge!!
	cloud-dns-manage add aj-alphabet-dev.palladi.us --ip  34.65.81.231

