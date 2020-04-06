# Makefile to generate QR codes of "Youscout for PTC".

#IMG_VIEW=cygstart
IMG_VIEW=echo
QR_VERSION=22

TARGET_DIR=qrcode_ysc
TARGET_DIR_MK=qrcode_mk
TARGET_DIR_HLP=qrcode_hlp
TARGET_NAME=YOUSCOUT
TARGET_NAME_MK=MKJRFTRT
TARGET_NAME_HLP=YSCHELP
SRC=youscout.prg trtconst.prg yscconst.prg stacklib.prg stdlib.prg ctrllib.prg jrftrt_p.prg yscmsg.prg
SRC_MK=mkjrftrt.prg trtconst.prg stacklib.prg stdlib.prg gputlib.prg jrftarot.prg
SRC_HLP=hlpview.prg yschlp.prg stacklib.prg stdlib.prg ctrllib.prg gputlib.prg yschlp_p.prg

all: ysc mk hlp

clean:
	-rm -r ${TARGET_DIR} ${TARGET_DIR_MK} ${TARGET_DIR_HLP}
	-rm jrftrt_p.prg yschlp_p.prg

ysc: ${TARGET_DIR}/qrcodes.html

mk: ${TARGET_DIR_MK}/qrcodes.html

hlp: ${TARGET_DIR_HLP}/qrcodes.html

${TARGET_DIR}/qrcodes.html: ${TARGET_DIR}/qr001.png make_qrcodes_html.pl
	perl make_qrcodes_html.pl -t ${TARGET_DIR} -N ${TARGET_NAME} --version-from youscout.prg

${TARGET_DIR_MK}/qrcodes.html: ${TARGET_DIR_MK}/qr001.png make_qrcodes_html.pl
	perl make_qrcodes_html.pl -t ${TARGET_DIR_MK} -N ${TARGET_NAME_MK} --version-from youscout.prg

${TARGET_DIR_HLP}/qrcodes.html: ${TARGET_DIR_HLP}/qr001.png make_qrcodes_html.pl
	perl make_qrcodes_html.pl -t ${TARGET_DIR_HLP} -N ${TARGET_NAME_HLP} --version-from youscout.prg

${TARGET_DIR}/qr001.png: ${SRC} gen_qrcode.pl
	-mkdir ${TARGET_DIR}
	-rm ${TARGET_DIR}/qr[01-9]*.png
	perl gen_qrcode.pl -Q ${QR_VERSION} --strict --no-check-global-once -N ${TARGET_NAME} -t ${TARGET_DIR} ${SRC}
	-${IMG_VIEW} ${TARGET_DIR}/qr001.png

${TARGET_DIR_MK}/qr001.png: ${SRC_MK} gen_qrcode.pl
	-mkdir ${TARGET_DIR_MK}
	-rm ${TARGET_DIR_MK}/qr[01-9]*.png
	perl gen_qrcode.pl -Q ${QR_VERSION} --strict --no-check-global-once -N ${TARGET_NAME_MK} -t ${TARGET_DIR_MK} ${SRC_MK}
	-${IMG_VIEW} ${TARGET_DIR_MK}/qr001.png

${TARGET_DIR_HLP}/qr001.png: ${SRC_HLP} gen_qrcode.pl
	-mkdir ${TARGET_DIR_HLP}
	-rm ${TARGET_DIR_HLP}/qr[01-9]*.png
	perl gen_qrcode.pl -Q ${QR_VERSION} --strict --no-check-global-once -N ${TARGET_NAME_HLP} -t ${TARGET_DIR_HLP} ${SRC_HLP}
	-${IMG_VIEW} ${TARGET_DIR_HLP}/qr001.png

jrftrt_p.prg: make_jrftrt_p.pl jrftarot.prg
	perl make_jrftrt_p.pl

yschlp_p.prg: make_yschlp_p.pl jrftarot.prg trtconst.prg yscconst.prg yscmsg.prg
	perl make_yschlp_p.pl

