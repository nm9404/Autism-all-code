function y = shut_down_curvelet_bands(Curvelets, subbands, zero_sub_band)
	featureVector=[];
	k = 1
	sb_1 = Curvelets{1}{1};
    [~,sc]=size(Curvelets);
    for i=1:sc
        scale=Curvelets{i};
        [~, ss]=size(scale);
        for j=1:ss
        	 if mean(double(ismember(k, subbands))) == 0
                 %disp(Curvelets{i}{j});
        	 	 Curvelets{i}{j} = 0;
        	 end
        	 k=k+1;
        end
    end
    if zero_sub_band
        Curvelets{1}{1}=sb_1;
    end
    y=Curvelets;
end