function y=getNormalizationCoeffScale(Curvelets)
	[~,sc]=size(Curvelets);
	NormalizationCoef=[];
	for i=1:sc
		Scale=Curvelets{i};
		[~,sb]=size(Scale);
		SubBandCoef=[];
		for j=1:sb
			SubbandMatrix=Scale{j};
			SubBandCoef=[SubBandCoef, reshape(SubbandMatrix, 1, [])];
		end
		NormalizationCoef=[NormalizationCoef, norm(SubBandCoef)];
	end
	y=NormalizationCoef;
end