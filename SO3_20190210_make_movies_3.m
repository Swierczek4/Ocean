
clear
close all
clc

tic()
acc_settings
load BGCObs
mask = permute(mask,[2,1,3]);

XC = rdmds('XC');
YC = rdmds('YC');
HC = rdmds('hFacC');
XC = XC(:,end);
YC = YC(end,:);

XC = XC(6:187);
YC = YC(6:127);
HC = HC(6:187,6:127,:);

vl = [4,16,27,30,36,41];
depth_names = [20,135,350,500,1000,1800];
coords = [ceil(XC(1)) floor(XC(end)) ceil(YC(1)) floor(YC(end))];
argo_depth = [10,33,52,58,69,78];
nn = 182;
mm = 122;
nlvls = 200;
str1 = '_mitgcm_ts_vl_';
str2 = '_bsose_ts_vl_';
strng = 'bluered2';
cm = acc_colormap(strng);

cm = [Color(:,46)';cm;Color(:,46)'];

for qq=1:6
    if qq==1
        THETA_Mooring = Obs_20;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    if qq==2
        THETA_Mooring = Obs_130;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    if qq==3
        THETA_Mooring = Obs_350;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    if qq==4
        THETA_Mooring = Obs_500;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    if qq==5
        THETA_Mooring = Obs_1000;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    if qq==6
        THETA_Mooring = Obs_1800;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    numdate = 736665;
    temp_str = num2str(vl(qq));
    temp_name = ['../SO3_20190210/diag/THETA',str1,temp_str,'.bin'];
    fid = fopen(temp_name,'r','b');
    U = fread(fid,inf,'single');
    NZ = length(U)/nn/mm;
    U = reshape(U,[nn,mm,NZ]);
    fclose(fid);
    U = permute(U,[2,1,3]);
    
    ind = find(U<9999998);
    ub = max(U(ind));
    lb = min(U(ind));
    if qq==1
        lb = -4;
    end
    if qq<3
        lb = -3;
    end
    z = linspace(lb,ub,nlvls);
    z = [-100000,z,9999998];
    dtstr_t = str2double(datestr(numdate,'yyyymmdd'));
    Obs_Array_t = THETA_Obs(THETA_Obs(:,1)==dtstr_t,[2,3,argo_depth(qq)]);
    Mooring = THETA_Mooring(THETA_Mooring(:,1)==dtstr_t,[3,2,4]);
    
    figure()
    set(gcf, 'Position', [1, 1, 1600, 900])
    colormap(cm)
    contourf(XC,YC,U(:,:,1),'LineStyle','none','LevelList',z);
    cbar = colorbar('eastoutside');
    set(cbar,'YLim',[lb ub]);
    hold on
    contour(XCm,YCm,mask(:,:,vl(qq)),'Color','k')
    scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),osz,'w','filled')
    scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),sz,Obs_Array_t(:,3),'filled')
    scatter(Mooring(1),Mooring(2),osz+50,'k','filled')
    scatter(Mooring(1),Mooring(2),sz+15,Mooring(3),'filled')
    caxis([lb ub])
    axis(coords)
    xtickformat('degrees')
    ytickformat('degrees')
    title(['MITGCM vs. Argo temperature (degrees C) at ',num2str(depth_names(qq)),'m depth during ',datestr(numdate,'yyyy mmm dd')],'FontWeight','Normal')
    acc_movie
    acc_plots
    hold off
    set(gca, 'nextplot','replacechildren', 'Visible','on');
    vidObj = VideoWriter(['THETA_MITGCM_OBS_',num2str(depth_names(qq)),'m.avi']);
    vidObj.Quality = 100;
    vidObj.FrameRate = 8;
    open(vidObj);
    writeVideo(vidObj, getframe(gcf));
    
    for ii=2:NZ
        numdate = numdate + 1;
        dtstr_t = str2double(datestr(numdate,'yyyymmdd'));
        Obs_Array_t = THETA_Obs(THETA_Obs(:,1)==dtstr_t,[2,3,argo_depth(qq)]);
        Obs_Array_t = Obs_Array_t(isnan(Obs_Array_t(:,3))==0,:);
        Mooring = THETA_Mooring(THETA_Mooring(:,1)==dtstr_t,[3,2,4]);
        
        dtstr_y1 = str2double(datestr(numdate-1,'yyyymmdd'));
        Obs_Array_y1 = THETA_Obs(THETA_Obs(:,1)==dtstr_y1,[2,3,argo_depth(qq)]);
        Obs_Array_y1 = Obs_Array_y1(isnan(Obs_Array_y1(:,3))==0,:);
        if ii>2
            dtstr_y2 = str2double(datestr(numdate-2,'yyyymmdd'));
            Obs_Array_y2 = THETA_Obs(THETA_Obs(:,1)==dtstr_y2,[2,3,argo_depth(qq)]);
            Obs_Array_y2 = Obs_Array_y2(isnan(Obs_Array_y2(:,3))==0,:);
        end
        if ii>3
            dtstr_y3 = str2double(datestr(numdate-3,'yyyymmdd'));
            Obs_Array_y3 = THETA_Obs(THETA_Obs(:,1)==dtstr_y3,[2,3,argo_depth(qq)]);
            Obs_Array_y3 = Obs_Array_y3(isnan(Obs_Array_y3(:,3))==0,:);
        end
        if ii<NZ
            dtstr_t1 = str2double(datestr(numdate+1,'yyyymmdd'));
            Obs_Array_t1 = THETA_Obs(THETA_Obs(:,1)==dtstr_t1,[2,3,argo_depth(qq)]);
            Obs_Array_t1 = Obs_Array_t1(isnan(Obs_Array_t1(:,3))==0,:);
        end
        if ii<NZ-1
            dtstr_t2 = str2double(datestr(numdate+2,'yyyymmdd'));
            Obs_Array_t2 = THETA_Obs(THETA_Obs(:,1)==dtstr_t2,[2,3,argo_depth(qq)]);
            Obs_Array_t2 = Obs_Array_t2(isnan(Obs_Array_t2(:,3))==0,:);
        end
        if ii<NZ-2
            dtstr_t3 = str2double(datestr(numdate+3,'yyyymmdd'));
            Obs_Array_t3 = THETA_Obs(THETA_Obs(:,1)==dtstr_t3,[2,3,argo_depth(qq)]);
            Obs_Array_t3 = Obs_Array_t3(isnan(Obs_Array_t3(:,3))==0,:);
        end
        
        contourf(XC,YC,U(:,:,ii),'LineStyle','none','LevelList',z);
        cbar = colorbar('eastoutside');
        set(cbar,'YLim',[lb ub]);
        hold on
        contour(XCm,YCm,mask(:,:,vl(qq)),'Color','k')
        scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),osz,'w','filled')
        scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),sz,Obs_Array_t(:,3),'filled')
        scatter(Obs_Array_y1(:,1),Obs_Array_y1(:,2),0.85*osz,'w','filled')
        scatter(Obs_Array_y1(:,1),Obs_Array_y1(:,2),0.85*sz,Obs_Array_y1(:,3),'filled')
        if ii>2
            scatter(Obs_Array_y2(:,1),Obs_Array_y2(:,2),0.70*osz,'w','filled')
            scatter(Obs_Array_y2(:,1),Obs_Array_y2(:,2),0.70*sz,Obs_Array_y2(:,3),'filled')
        end
        if ii>3
            scatter(Obs_Array_y3(:,1),Obs_Array_y3(:,2),0.525*osz,'w','filled')
            scatter(Obs_Array_y3(:,1),Obs_Array_y3(:,2),0.525*sz,Obs_Array_y3(:,3),'filled')
        end
        if ii<NZ
            scatter(Obs_Array_t1(:,1),Obs_Array_t1(:,2),0.85*osz,'w','filled')
            scatter(Obs_Array_t1(:,1),Obs_Array_t1(:,2),0.85*sz,Obs_Array_t1(:,3),'filled')
        end
        if ii<NZ-1
            scatter(Obs_Array_t2(:,1),Obs_Array_t2(:,2),0.70*osz,'w','filled')
            scatter(Obs_Array_t2(:,1),Obs_Array_t2(:,2),0.70*sz,Obs_Array_t2(:,3),'filled')
        end
        if ii<NZ-2
            scatter(Obs_Array_t3(:,1),Obs_Array_t3(:,2),0.525*osz,'w','filled')
            scatter(Obs_Array_t3(:,1),Obs_Array_t3(:,2),0.525*sz,Obs_Array_t3(:,3),'filled')
        end
        if isempty(Mooring)==0
            scatter(Mooring(1),Mooring(2),osz+50,'k','filled')
            scatter(Mooring(1),Mooring(2),sz+15,Mooring(3),'filled')
        end
        caxis([lb ub])
        axis(coords)
        title(['MITGCM vs. Argo temperature (degrees C) at ',num2str(depth_names(qq)),'m depth during ',datestr(numdate,'yyyy mmm dd')],'FontWeight','Normal')
        xtickformat('degrees')
        ytickformat('degrees')
        acc_movie
        drawnow()
        writeVideo(vidObj, getframe(gcf));
        hold off
    end
    
    close(vidObj);
    close all
    clear z U
end

for qq=1:6
    if qq==1
        SALT_Mooring = Obs_20;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    if qq==2
        SALT_Mooring = Obs_130;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    if qq==3
        SALT_Mooring = Obs_350;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    if qq==4
        SALT_Mooring = Obs_500;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    if qq==5
        SALT_Mooring = Obs_1000;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    if qq==6
        SALT_Mooring = Obs_1800;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    numdate = 736665;
    temp_str = num2str(vl(qq));
    temp_name = ['../SO3_20190210/diag/SALT',str1,temp_str,'.bin'];
    fid = fopen(temp_name,'r','b');
    U = fread(fid,inf,'single');
    NZ = length(U)/nn/mm;
    U = reshape(U,[nn,mm,NZ]);
    fclose(fid);
    U = permute(U,[2,1,3]);
    
    ind = find(U<9999998);
    ub = max(U(ind));
    lb = min(U(ind));
    if qq==1
        lb = 30;
    end
    if qq>1
        lb = 33;
    end
    if qq==5
        ub = 35;
        lb = 34;
    end
    if qq==6
        ub = 35;
        lb = 34.4;
    end    
        
    z = linspace(lb,ub,nlvls);
    z = [-100000,z,9999998];
    dtstr_t = str2double(datestr(numdate,'yyyymmdd'));
    Obs_Array_t = SALT_Obs(SALT_Obs(:,1)==dtstr_t,[2,3,argo_depth(qq)]);
    Mooring = SALT_Mooring(SALT_Mooring(:,1)==dtstr_t,[3,2,5]);
    
    figure()
    set(gcf, 'Position', [1, 1, 1600, 900])
    colormap(cm)
    contourf(XC,YC,U(:,:,1),'LineStyle','none','LevelList',z);
    cbar = colorbar('eastoutside');
    set(cbar,'YLim',[lb ub]);
    hold on
    contour(XCm,YCm,mask(:,:,vl(qq)),'Color','k')
    scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),osz,'w','filled')
    scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),sz,Obs_Array_t(:,3),'filled')
    scatter(Mooring(1),Mooring(2),osz+50,'k','filled')
    scatter(Mooring(1),Mooring(2),sz+15,Mooring(3),'filled')    
    caxis([lb ub])
    axis(coords)
    xtickformat('degrees')
    ytickformat('degrees')
    title(['MITGCM vs. Argo salinity (psu) at ',num2str(depth_names(qq)),'m depth during ',datestr(numdate,'yyyy mmm dd')],'FontWeight','Normal')
    acc_movie
    acc_plots
    hold off
    set(gca, 'nextplot','replacechildren', 'Visible','on');
    vidObj = VideoWriter(['SALT_MITGCM_OBS_',num2str(depth_names(qq)),'m.avi']);
    vidObj.Quality = 100;
    vidObj.FrameRate = 8;
    open(vidObj);
    writeVideo(vidObj, getframe(gcf));
    
    for ii=2:NZ
        numdate = numdate + 1;
        dtstr_t = str2double(datestr(numdate,'yyyymmdd'));
        Obs_Array_t = SALT_Obs(SALT_Obs(:,1)==dtstr_t,[2,3,argo_depth(qq)]);
        Obs_Array_t = Obs_Array_t(isnan(Obs_Array_t(:,3))==0,:);
        Mooring = SALT_Mooring(SALT_Mooring(:,1)==dtstr_t,[3,2,5]);
        dtstr_y1 = str2double(datestr(numdate-1,'yyyymmdd'));
        Obs_Array_y1 = SALT_Obs(SALT_Obs(:,1)==dtstr_y1,[2,3,argo_depth(qq)]);
        Obs_Array_y1 = Obs_Array_y1(isnan(Obs_Array_y1(:,3))==0,:);
        if ii>2
            dtstr_y2 = str2double(datestr(numdate-2,'yyyymmdd'));
            Obs_Array_y2 = SALT_Obs(SALT_Obs(:,1)==dtstr_y2,[2,3,argo_depth(qq)]);
            Obs_Array_y2 = Obs_Array_y2(isnan(Obs_Array_y2(:,3))==0,:);
        end
        if ii>3
            dtstr_y3 = str2double(datestr(numdate-3,'yyyymmdd'));
            Obs_Array_y3 = SALT_Obs(SALT_Obs(:,1)==dtstr_y3,[2,3,argo_depth(qq)]);
            Obs_Array_y3 = Obs_Array_y3(isnan(Obs_Array_y3(:,3))==0,:);
        end
        if ii<NZ
            dtstr_t1 = str2double(datestr(numdate+1,'yyyymmdd'));
            Obs_Array_t1 = SALT_Obs(SALT_Obs(:,1)==dtstr_t1,[2,3,argo_depth(qq)]);
            Obs_Array_t1 = Obs_Array_t1(isnan(Obs_Array_t1(:,3))==0,:);
        end
        if ii<NZ-1
            dtstr_t2 = str2double(datestr(numdate+2,'yyyymmdd'));
            Obs_Array_t2 = SALT_Obs(SALT_Obs(:,1)==dtstr_t2,[2,3,argo_depth(qq)]);
            Obs_Array_t2 = Obs_Array_t2(isnan(Obs_Array_t2(:,3))==0,:);
        end
        if ii<NZ-2
            dtstr_t3 = str2double(datestr(numdate+3,'yyyymmdd'));
            Obs_Array_t3 = SALT_Obs(SALT_Obs(:,1)==dtstr_t3,[2,3,argo_depth(qq)]);
            Obs_Array_t3 = Obs_Array_t3(isnan(Obs_Array_t3(:,3))==0,:);
        end
        
        contourf(XC,YC,U(:,:,ii),'LineStyle','none','LevelList',z);
        cbar = colorbar('eastoutside');
        set(cbar,'YLim',[lb ub]);
        hold on
        contour(XCm,YCm,mask(:,:,vl(qq)),'Color','k')
        scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),osz,'w','filled')
        scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),sz,Obs_Array_t(:,3),'filled')
        scatter(Obs_Array_y1(:,1),Obs_Array_y1(:,2),0.85*osz,'w','filled')
        scatter(Obs_Array_y1(:,1),Obs_Array_y1(:,2),0.85*sz,Obs_Array_y1(:,3),'filled')
        if ii>2
            scatter(Obs_Array_y2(:,1),Obs_Array_y2(:,2),0.70*osz,'w','filled')
            scatter(Obs_Array_y2(:,1),Obs_Array_y2(:,2),0.70*sz,Obs_Array_y2(:,3),'filled')
        end
        if ii>3
            scatter(Obs_Array_y3(:,1),Obs_Array_y3(:,2),0.525*osz,'w','filled')
            scatter(Obs_Array_y3(:,1),Obs_Array_y3(:,2),0.525*sz,Obs_Array_y3(:,3),'filled')
        end
        if ii<NZ
            scatter(Obs_Array_t1(:,1),Obs_Array_t1(:,2),0.85*osz,'w','filled')
            scatter(Obs_Array_t1(:,1),Obs_Array_t1(:,2),0.85*sz,Obs_Array_t1(:,3),'filled')
        end
        if ii<NZ-1
            scatter(Obs_Array_t2(:,1),Obs_Array_t2(:,2),0.70*osz,'w','filled')
            scatter(Obs_Array_t2(:,1),Obs_Array_t2(:,2),0.70*sz,Obs_Array_t2(:,3),'filled')
        end
        if ii<NZ-2
            scatter(Obs_Array_t3(:,1),Obs_Array_t3(:,2),0.525*osz,'w','filled')
            scatter(Obs_Array_t3(:,1),Obs_Array_t3(:,2),0.525*sz,Obs_Array_t3(:,3),'filled')
        end
        if isempty(Mooring)==0
            scatter(Mooring(1),Mooring(2),osz+50,'k','filled')
            scatter(Mooring(1),Mooring(2),sz+15,Mooring(3),'filled')
        end
        caxis([lb ub])
        axis(coords)
        title(['MITGCM vs. Argo salinity (psu) at ',num2str(depth_names(qq)),'m depth during ',datestr(numdate,'yyyy mmm dd')],'FontWeight','Normal')
        xtickformat('degrees')
        ytickformat('degrees')
        acc_movie
        drawnow()
        writeVideo(vidObj, getframe(gcf));
        hold off
    end
    
    close(vidObj);
    close all
    clear z U
end

for qq=1:6
    if qq==1
        THETA_Mooring = Obs_20;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    if qq==2
        THETA_Mooring = Obs_130;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    if qq==3
        THETA_Mooring = Obs_350;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    if qq==4
        THETA_Mooring = Obs_500;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    if qq==5
        THETA_Mooring = Obs_1000;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    if qq==6
        THETA_Mooring = Obs_1800;
        THETA_Mooring = THETA_Mooring(isnan(THETA_Mooring(:,4))==0,:);
    end
    numdate = 736665;
    temp_str = num2str(vl(qq));
    temp_name = ['../SO3_20190210/diag/THETA',str1,temp_str,'.bin'];
    fid = fopen(temp_name,'r','b');
    U = fread(fid,inf,'single');
    NZ = length(U)/nn/mm;
    U = reshape(U,[nn,mm,NZ]);
    fclose(fid);
    U = permute(U,[2,1,3]);
    
    ind = find(U<9999998);
    ub = max(U(ind));
    lb = min(U(ind));
    if qq==1
        lb = -4;
    end
    if qq<3
        lb = -3;
    end
    z = linspace(lb,ub,nlvls);
    z = [-100000,z,9999998];
    dtstr_t = str2double(datestr(numdate,'yyyymmdd'));
    Obs_Array_t = THETA_Obs(THETA_Obs(:,1)==dtstr_t,[2,3,argo_depth(qq)]);
    Mooring = THETA_Mooring(THETA_Mooring(:,1)==dtstr_t,[3,2,4]);
    
    figure()
    set(gcf, 'Position', [1, 1, 1600, 900])
    colormap(cm)
    contourf(XC,YC,U(:,:,1),'LineStyle','none','LevelList',z);
    cbar = colorbar('eastoutside');
    set(cbar,'YLim',[lb ub]);
    hold on
    contour(XCm,YCm,mask(:,:,vl(qq)),'Color','k')
    scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),osz,'w','filled')
    scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),sz,Obs_Array_t(:,3),'filled')
    scatter(Mooring(1),Mooring(2),osz+50,'k','filled')
    scatter(Mooring(1),Mooring(2),sz+15,Mooring(3),'filled')
    caxis([lb ub])
    axis(coords)
    xtickformat('degrees')
    ytickformat('degrees')
    title(['MITGCM vs. Argo temperature (degrees C) at ',num2str(depth_names(qq)),'m depth during ',datestr(numdate,'yyyy mmm dd')],'FontWeight','Normal')
    acc_movie
    acc_plots
    hold off
    set(gca, 'nextplot','replacechildren', 'Visible','on');
    vidObj = VideoWriter(['THETA_MITGCM_OBS_',num2str(depth_names(qq)),'m.avi']);
    vidObj.Quality = 100;
    vidObj.FrameRate = 8;
    open(vidObj);
    writeVideo(vidObj, getframe(gcf));
    
    for ii=2:NZ
        numdate = numdate + 1;
        dtstr_t = str2double(datestr(numdate,'yyyymmdd'));
        Obs_Array_t = THETA_Obs(THETA_Obs(:,1)==dtstr_t,[2,3,argo_depth(qq)]);
        Obs_Array_t = Obs_Array_t(isnan(Obs_Array_t(:,3))==0,:);
        Mooring = THETA_Mooring(THETA_Mooring(:,1)==dtstr_t,[3,2,4]);
        
        dtstr_y1 = str2double(datestr(numdate-1,'yyyymmdd'));
        Obs_Array_y1 = THETA_Obs(THETA_Obs(:,1)==dtstr_y1,[2,3,argo_depth(qq)]);
        Obs_Array_y1 = Obs_Array_y1(isnan(Obs_Array_y1(:,3))==0,:);
        if ii>2
            dtstr_y2 = str2double(datestr(numdate-2,'yyyymmdd'));
            Obs_Array_y2 = THETA_Obs(THETA_Obs(:,1)==dtstr_y2,[2,3,argo_depth(qq)]);
            Obs_Array_y2 = Obs_Array_y2(isnan(Obs_Array_y2(:,3))==0,:);
        end
        if ii>3
            dtstr_y3 = str2double(datestr(numdate-3,'yyyymmdd'));
            Obs_Array_y3 = THETA_Obs(THETA_Obs(:,1)==dtstr_y3,[2,3,argo_depth(qq)]);
            Obs_Array_y3 = Obs_Array_y3(isnan(Obs_Array_y3(:,3))==0,:);
        end
        if ii<NZ
            dtstr_t1 = str2double(datestr(numdate+1,'yyyymmdd'));
            Obs_Array_t1 = THETA_Obs(THETA_Obs(:,1)==dtstr_t1,[2,3,argo_depth(qq)]);
            Obs_Array_t1 = Obs_Array_t1(isnan(Obs_Array_t1(:,3))==0,:);
        end
        if ii<NZ-1
            dtstr_t2 = str2double(datestr(numdate+2,'yyyymmdd'));
            Obs_Array_t2 = THETA_Obs(THETA_Obs(:,1)==dtstr_t2,[2,3,argo_depth(qq)]);
            Obs_Array_t2 = Obs_Array_t2(isnan(Obs_Array_t2(:,3))==0,:);
        end
        if ii<NZ-2
            dtstr_t3 = str2double(datestr(numdate+3,'yyyymmdd'));
            Obs_Array_t3 = THETA_Obs(THETA_Obs(:,1)==dtstr_t3,[2,3,argo_depth(qq)]);
            Obs_Array_t3 = Obs_Array_t3(isnan(Obs_Array_t3(:,3))==0,:);
        end
        
        contourf(XC,YC,U(:,:,ii),'LineStyle','none','LevelList',z);
        cbar = colorbar('eastoutside');
        set(cbar,'YLim',[lb ub]);
        hold on
        contour(XCm,YCm,mask(:,:,vl(qq)),'Color','k')
        scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),osz,'w','filled')
        scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),sz,Obs_Array_t(:,3),'filled')
        scatter(Obs_Array_y1(:,1),Obs_Array_y1(:,2),0.85*osz,'w','filled')
        scatter(Obs_Array_y1(:,1),Obs_Array_y1(:,2),0.85*sz,Obs_Array_y1(:,3),'filled')
        if ii>2
            scatter(Obs_Array_y2(:,1),Obs_Array_y2(:,2),0.70*osz,'w','filled')
            scatter(Obs_Array_y2(:,1),Obs_Array_y2(:,2),0.70*sz,Obs_Array_y2(:,3),'filled')
        end
        if ii>3
            scatter(Obs_Array_y3(:,1),Obs_Array_y3(:,2),0.525*osz,'w','filled')
            scatter(Obs_Array_y3(:,1),Obs_Array_y3(:,2),0.525*sz,Obs_Array_y3(:,3),'filled')
        end
        if ii<NZ
            scatter(Obs_Array_t1(:,1),Obs_Array_t1(:,2),0.85*osz,'w','filled')
            scatter(Obs_Array_t1(:,1),Obs_Array_t1(:,2),0.85*sz,Obs_Array_t1(:,3),'filled')
        end
        if ii<NZ-1
            scatter(Obs_Array_t2(:,1),Obs_Array_t2(:,2),0.70*osz,'w','filled')
            scatter(Obs_Array_t2(:,1),Obs_Array_t2(:,2),0.70*sz,Obs_Array_t2(:,3),'filled')
        end
        if ii<NZ-2
            scatter(Obs_Array_t3(:,1),Obs_Array_t3(:,2),0.525*osz,'w','filled')
            scatter(Obs_Array_t3(:,1),Obs_Array_t3(:,2),0.525*sz,Obs_Array_t3(:,3),'filled')
        end
        if isempty(Mooring)==0
            scatter(Mooring(1),Mooring(2),osz+50,'k','filled')
            scatter(Mooring(1),Mooring(2),sz+15,Mooring(3),'filled')
        end
        caxis([lb ub])
        axis(coords)
        title(['MITGCM vs. Argo temperature (degrees C) at ',num2str(depth_names(qq)),'m depth during ',datestr(numdate,'yyyy mmm dd')],'FontWeight','Normal')
        xtickformat('degrees')
        ytickformat('degrees')
        acc_movie
        drawnow()
        writeVideo(vidObj, getframe(gcf));
        hold off
    end
    
    close(vidObj);
    close all
    clear z U
end

for qq=1:6
    if qq==1
        SALT_Mooring = Obs_20;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    if qq==2
        SALT_Mooring = Obs_130;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    if qq==3
        SALT_Mooring = Obs_350;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    if qq==4
        SALT_Mooring = Obs_500;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    if qq==5
        SALT_Mooring = Obs_1000;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    if qq==6
        SALT_Mooring = Obs_1800;
        SALT_Mooring = SALT_Mooring(isnan(SALT_Mooring(:,5))==0,:);
    end
    numdate = 736665;
    temp_str = num2str(vl(qq));
    temp_name = ['../SO3_20190210/diag/SALT',str1,temp_str,'.bin'];
    fid = fopen(temp_name,'r','b');
    U = fread(fid,inf,'single');
    NZ = length(U)/nn/mm;
    U = reshape(U,[nn,mm,NZ]);
    fclose(fid);
    U = permute(U,[2,1,3]);
    
    ind = find(U<9999998);
    ub = max(U(ind));
    lb = min(U(ind));
    if qq==1
        lb = 30;
    end
    if qq>1
        lb = 33;
    end
    if qq==5
        ub = 35;
        lb = 34;
    end
    if qq==6
        ub = 35;
        lb = 34.4;
    end    
        
    z = linspace(lb,ub,nlvls);
    z = [-100000,z,9999998];
    dtstr_t = str2double(datestr(numdate,'yyyymmdd'));
    Obs_Array_t = SALT_Obs(SALT_Obs(:,1)==dtstr_t,[2,3,argo_depth(qq)]);
    Mooring = SALT_Mooring(SALT_Mooring(:,1)==dtstr_t,[3,2,5]);
    
    figure()
    set(gcf, 'Position', [1, 1, 1600, 900])
    colormap(cm)
    contourf(XC,YC,U(:,:,1),'LineStyle','none','LevelList',z);
    cbar = colorbar('eastoutside');
    set(cbar,'YLim',[lb ub]);
    hold on
    contour(XCm,YCm,mask(:,:,vl(qq)),'Color','k')
    scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),osz,'w','filled')
    scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),sz,Obs_Array_t(:,3),'filled')
    scatter(Mooring(1),Mooring(2),osz+50,'k','filled')
    scatter(Mooring(1),Mooring(2),sz+15,Mooring(3),'filled')    
    caxis([lb ub])
    axis(coords)
    xtickformat('degrees')
    ytickformat('degrees')
    title(['MITGCM vs. Argo salinity (psu) at ',num2str(depth_names(qq)),'m depth during ',datestr(numdate,'yyyy mmm dd')],'FontWeight','Normal')
    acc_movie
    acc_plots
    hold off
    set(gca, 'nextplot','replacechildren', 'Visible','on');
    vidObj = VideoWriter(['SALT_MITGCM_OBS_',num2str(depth_names(qq)),'m.avi']);
    vidObj.Quality = 100;
    vidObj.FrameRate = 8;
    open(vidObj);
    writeVideo(vidObj, getframe(gcf));
    
    for ii=2:NZ
        numdate = numdate + 1;
        dtstr_t = str2double(datestr(numdate,'yyyymmdd'));
        Obs_Array_t = SALT_Obs(SALT_Obs(:,1)==dtstr_t,[2,3,argo_depth(qq)]);
        Obs_Array_t = Obs_Array_t(isnan(Obs_Array_t(:,3))==0,:);
        Mooring = SALT_Mooring(SALT_Mooring(:,1)==dtstr_t,[3,2,5]);
        dtstr_y1 = str2double(datestr(numdate-1,'yyyymmdd'));
        Obs_Array_y1 = SALT_Obs(SALT_Obs(:,1)==dtstr_y1,[2,3,argo_depth(qq)]);
        Obs_Array_y1 = Obs_Array_y1(isnan(Obs_Array_y1(:,3))==0,:);
        if ii>2
            dtstr_y2 = str2double(datestr(numdate-2,'yyyymmdd'));
            Obs_Array_y2 = SALT_Obs(SALT_Obs(:,1)==dtstr_y2,[2,3,argo_depth(qq)]);
            Obs_Array_y2 = Obs_Array_y2(isnan(Obs_Array_y2(:,3))==0,:);
        end
        if ii>3
            dtstr_y3 = str2double(datestr(numdate-3,'yyyymmdd'));
            Obs_Array_y3 = SALT_Obs(SALT_Obs(:,1)==dtstr_y3,[2,3,argo_depth(qq)]);
            Obs_Array_y3 = Obs_Array_y3(isnan(Obs_Array_y3(:,3))==0,:);
        end
        if ii<NZ
            dtstr_t1 = str2double(datestr(numdate+1,'yyyymmdd'));
            Obs_Array_t1 = SALT_Obs(SALT_Obs(:,1)==dtstr_t1,[2,3,argo_depth(qq)]);
            Obs_Array_t1 = Obs_Array_t1(isnan(Obs_Array_t1(:,3))==0,:);
        end
        if ii<NZ-1
            dtstr_t2 = str2double(datestr(numdate+2,'yyyymmdd'));
            Obs_Array_t2 = SALT_Obs(SALT_Obs(:,1)==dtstr_t2,[2,3,argo_depth(qq)]);
            Obs_Array_t2 = Obs_Array_t2(isnan(Obs_Array_t2(:,3))==0,:);
        end
        if ii<NZ-2
            dtstr_t3 = str2double(datestr(numdate+3,'yyyymmdd'));
            Obs_Array_t3 = SALT_Obs(SALT_Obs(:,1)==dtstr_t3,[2,3,argo_depth(qq)]);
            Obs_Array_t3 = Obs_Array_t3(isnan(Obs_Array_t3(:,3))==0,:);
        end
        
        contourf(XC,YC,U(:,:,ii),'LineStyle','none','LevelList',z);
        cbar = colorbar('eastoutside');
        set(cbar,'YLim',[lb ub]);
        hold on
        contour(XCm,YCm,mask(:,:,vl(qq)),'Color','k')
        scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),osz,'w','filled')
        scatter(Obs_Array_t(:,1),Obs_Array_t(:,2),sz,Obs_Array_t(:,3),'filled')
        scatter(Obs_Array_y1(:,1),Obs_Array_y1(:,2),0.85*osz,'w','filled')
        scatter(Obs_Array_y1(:,1),Obs_Array_y1(:,2),0.85*sz,Obs_Array_y1(:,3),'filled')
        if ii>2
            scatter(Obs_Array_y2(:,1),Obs_Array_y2(:,2),0.70*osz,'w','filled')
            scatter(Obs_Array_y2(:,1),Obs_Array_y2(:,2),0.70*sz,Obs_Array_y2(:,3),'filled')
        end
        if ii>3
            scatter(Obs_Array_y3(:,1),Obs_Array_y3(:,2),0.525*osz,'w','filled')
            scatter(Obs_Array_y3(:,1),Obs_Array_y3(:,2),0.525*sz,Obs_Array_y3(:,3),'filled')
        end
        if ii<NZ
            scatter(Obs_Array_t1(:,1),Obs_Array_t1(:,2),0.85*osz,'w','filled')
            scatter(Obs_Array_t1(:,1),Obs_Array_t1(:,2),0.85*sz,Obs_Array_t1(:,3),'filled')
        end
        if ii<NZ-1
            scatter(Obs_Array_t2(:,1),Obs_Array_t2(:,2),0.70*osz,'w','filled')
            scatter(Obs_Array_t2(:,1),Obs_Array_t2(:,2),0.70*sz,Obs_Array_t2(:,3),'filled')
        end
        if ii<NZ-2
            scatter(Obs_Array_t3(:,1),Obs_Array_t3(:,2),0.525*osz,'w','filled')
            scatter(Obs_Array_t3(:,1),Obs_Array_t3(:,2),0.525*sz,Obs_Array_t3(:,3),'filled')
        end
        if isempty(Mooring)==0
            scatter(Mooring(1),Mooring(2),osz+50,'k','filled')
            scatter(Mooring(1),Mooring(2),sz+15,Mooring(3),'filled')
        end
        caxis([lb ub])
        axis(coords)
        title(['MITGCM vs. Argo salinity (psu) at ',num2str(depth_names(qq)),'m depth during ',datestr(numdate,'yyyy mmm dd')],'FontWeight','Normal')
        xtickformat('degrees')
        ytickformat('degrees')
        acc_movie
        drawnow()
        writeVideo(vidObj, getframe(gcf));
        hold off
    end
    
    close(vidObj);
    close all
    clear z U
end