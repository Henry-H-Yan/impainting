function im_diffused = anisoDiffusion(path_data, name, param_aniso, general_settings)

    num_iter = param_aniso.num_iter; 
    delta_t = param_aniso.delta_t;
    kappa = param_aniso.kappa;
    option = param_aniso.option;
    
    fileset = dir([path_data '*' name '*' ]);
    
    for i = 1:length(fileset)
        im = imread([path_data fileset(i).name]);
        [im_h im_w] = size(im);
        im = im2double(im);
        im = padarray(im,[3 3],'replicate');
        num = strtok(fileset(i).name, '_');
        ad = anisodiff2D(im,num_iter,delta_t,kappa,option);
        ad = ad(4:3+im_h, 4:3+im_w);
        imwrite(ad, [path_data num '_anisodiff.tif'])
    end
    
    im_diffused = recombineBlocks(path_data, '_anisodiff', general_settings);
    
