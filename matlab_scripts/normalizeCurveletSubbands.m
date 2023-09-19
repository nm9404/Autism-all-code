function y=normalizeCurveletSubbands(Curvelets)
	CurveletsCopy=Curvelets;
	[~,sc]=size(Curvelets);
	NormalizationCoef=[];
	for i=1:sc
		Scale=Curvelets{i};
		[~,sb]=size(Scale);
		SubBandCoef=[];
		for j=1:sb
			CurveletsCopy{i}{j}=(1/max(Curvelets{i}{j}, [], 'all'))*Curvelets{i}{j};
		end
	end
	y=CurveletsCopy;
end