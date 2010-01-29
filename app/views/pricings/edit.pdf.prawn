pdf.font "/usr/share/fonts/truetype/msttcorefonts/arial.ttf" 
pdf.font_size = 11
pigs = "public/images/logos/cube_hi.jpg" 
latsx = "public/images/logos/sx.jpg" 
latdx = "public/images/logos/dx.jpg" 
pdf.canvas do
	
	pdf.image latsx, :at => [0,842] 
	pdf.image latdx, :at => [554,346]
end
pdf.image pigs, :at => [2,790], :fit => [200,50]
pdf.cell [400,790],:width=>200,:text=>@company.ragionesociale,:border_width=>0,:text_color=>"A50000"
