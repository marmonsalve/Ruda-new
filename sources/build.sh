
#!/bin/sh
set -e





echo "Generating VFs"
mkdir -p ../fonts/vf
fontmake -m Ruda.designspace -o variable --output-path ../fonts/vf/Ruda[wght].ttf

rm -rf master_ufo/ instance_ufo/ instance_ufos/*



vfs=$(ls ../fonts/vf/*\[wght\].ttf)

echo "Post processing VFs"
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	# disable hinting
	#ttfautohint --stem-width-mode nnn $vf "$vf.fix";
	#mv "$vf.fix" $vf;
done




echo "Fixing VF Meta"
gftools fix-vf-meta $vfs;

echo "Dropping MVAR"
for vf in $vfs
do
	# mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/vf/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done



echo "Fixing Hinting"
FONTSVF=$(ls ../fonts/vf/*.ttf)
for font in $FONTSVF
do
  gftools fix-nonhinting $font "$font.fix"
  if [ -f "$font.fix" ]; then mv "$font.fix" $vf; fi
done



echo "Generating Static fonts"
mkdir -p ../fonts
fontmake -m Ruda.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake -m Ruda.designspace -i -o otf --output-dir ../fonts/otf/

rm -rf master_ufo/ instance_ufo/ instance_ufos/*

echo "Post processing"
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	# disable hinting
	#ttfautohint $ttf "$ttf.fix";
	#mv "$ttf.fix" $ttf;
done

for ttf in $ttfs
do
	gftools fix-nonhinting $ttf "$ttf.fix";
	if [ -f "$ttf.fix" ]; then mv "$ttf.fix" $ttf; fi
done

