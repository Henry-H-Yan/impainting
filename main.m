close all;     clc;
addpath('ksvdbox13/');  addpath('ompbox10/');  addpath('results/');
configuration;

%-----------------------------------------------------------------------%
%    DEFAULT VALUES!
%param_ksvd = 
% 
%         blocksize: 16
%          dictsize: 128
%           iternum: 20
%             Tdata: 1
%          trainnum: 50000
%          memusage: 'high'
%           verbose: 't'
%               th1: 0.2000
%               th2: 0.1500
%     path_training: 'data_ksvdtraining/test1.tif'
%       path_result: 'results/ksvd/'
%-----------------------------------------------------------------------% 
param_ksvd.path_training= 'data_ksvdtraining/test4.tif';
sw_contrastenhance = true;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------- Alterations -------------
%
param_ksvd.dictsize=160;                                         %
note='dict160';                                             %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%From 1 to N
% n=64;
% filenames=cell(1,n);  % preallocating space
%
% for i=1:n;
%     if(i<=9)
%         temp= strcat('0',num2str(i),'_enhanced.tif');
%     else
%         temp=  strcat(num2str(i),'_enhanced.tif');
%     end
%
%     filenames{i}=temp;
% end

% Specified by user

input= [ 8];
n = size(input,2);
filenames=cell(1,n);  %pre-allocate!

for i= 1:n
    num=input(i);  % integer
    if(num<=9)
        temp= strcat('0',num2str(num),'_enhanced.tif');
    else
        temp=  strcat(num2str(num),'_enhanced.tif');
    end
    
    filenames{i}=temp;
end



for i = 1:length(filenames)
    
    image_name = strtok(filenames{i},'.');   %get name
    fprintf(image_name);
    fprintf('\n');
    % -- preprocessing --
    
    % im = imread(strcat(path_data.source,filenames{i}));
    
    % temporary path
    tempPath= strcat( 'data_blocks/Ghissi18/', filenames{i});
    %fprintf (tempPath);
    
    
    
    im = imread( tempPath );
    [im,im_enh] = prepareData(im, image_name, path_data.planes, path_data.enhanced, sw_contrastenhance);
    [im_h im_w] = size(im);
    
    % -- divide in blocks if too large --
    makeBlocks(im, image_name, path_data.blocks, 'gray', general);
    makeBlocks(im_enh, image_name, path_data.blocks, 'enhanced', general);
    
    % -- anisotropic diffusion --
    im_diffused = anisoDiffusion([path_data.blocks image_name general.escape_char] , 'enhanced', param_aniso, general);
    imwrite(uint8(im_diffused), [path_data.enhanced image_name general.escape_char 'anisodiff.tif']);
    
  
    % -- crack detection: KSVD -- %
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    -- Currently using im-enh  - enhanced?? 
    % %%%%%%%%%%%%%%%%%%%   where does param_ksvd come from???  it's a
    % 
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % - comment to save running time!
    % map3 = ksvdDetection(im_enh, param_ksvd, 1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mkdir([param_ksvd.path_result image_name general.escape_char]);
    
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Name file properly!!!
    tempStr= strcat(image_name,' ', note,'.tif');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    
    imwrite(map3, [param_ksvd.path_result image_name general.escape_char  tempStr]);
    
    
    %Show Graph
    figure(n); title(tempStr);imshow(map3); 
    
    
     %     % -- crack detection: elongated filters -- %
    %     elongated_filters = createElongatedFilters(param_elongfilt);
    %     map1 = batchFiltering_inv([path_data.blocks image_name general.escape_char], '_enh', -elongated_filters, param_elongfilt, general);
    %     mkdir([param_elongfilt.path_result image_name general.escape_char]);
    %     imwrite(map1, [param_elongfilt.path_result image_name general.escape_char 'mask_inv.tif']);
    %
    %     figure, imshow(im);
    %     figure, imshow(map1);
    %     im_rgb = markCracks(im,map1,[1 0 0]);
    %     figure, imshow(im_rgb);
    
    %     % -- crack detection: Top Hat transform -- %
    %     map2 = bottomhatTransform([path_data.enhanced image_name general.escape_char], 'gray', param_tophat, general);
    %     mkdir([param_tophat.path_result image_name general.escape_char]);
    %     imwrite(map2, [param_tophat.path_result image_name general.escape_char 'mask_inv.tif']);
    %
    %
    
    
    %  -- Crack Detection ends Here --%
    
    
    
    %     -- Gathering of features --%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        path_result = param_ksvd.path_result;
       path_data.source='data_blocks/08_enhanced/';
       filenames{i}='01_enhanced.tif';
        path_im_crack=strcat('results/ksvd/', image_name);
      
        
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
        createColorplanes(path_data.source, filenames{i}, path_data.planes, general);
        
        
        saveSkeleton([path_result image_name general.escape_char 'PARAMSmask.tif'], image_name, path_result, 3, general);
        [featArray, feature_vector] = gatherAllFeatures(path_result, image_name, general, post_proc, path_data);
        save([path_result image_name general.escape_char 'FeatArray.mat'], 'featArray');
        cleaned_map = kmeansFiltering([path_result image_name general.escape_char],post_proc.selectedFeatures);
        imwrite(cleaned_map, [path_result image_name general.escape_char 'cleaned_mask.tif']);
        
        fprintf('reached end');
    
    
    
    %     % -- Post processing: combine results -- %
    %     maps_path{1} = [param_ksvd.path_result image_name general.escape_char];
    %     maps_path{2} = [param_elongfilt.path_result image_name general.escape_char];
    %     maps_path{3} = [param_tophat.path_result image_name general.escape_char];
    %     final_map = voting(maps_path);
    %
    %     file_to_check = [path_data.planes image_name '/gray.tif'];
    %     im = imread(file_to_check,'tif');
    %     im = im2double(im);
    %     rgb_color = [1 0 0];
    %     im_rgb = markCracks(im,final_map,rgb_color);
    %
    %     mkdir([path_data.final_result image_name]);
    %     imwrite(final_map, [path_data.final_result image_name general.escape_char 'final_mask.tif']);
    %     imwrite(im_rgb, [path_data.final_result image_name general.escape_char 'final_overlap.tif']);
    
    
end




