clear all
close all


[train_data, train_labels, test_data, test_labels] = readDATA();
[train_x,train_y,test_x,test_y]=transformDATA();

cnn.layers={struct('type','L1')%  �����
    struct('type','C2','outputmaps',8,'kernelsize',64,'stride',1)% �����
    struct('type','C3','outputmaps',5,'kernelsize',10,'stride',10)% ���+��������
    struct('type','F4','n_hidden',100)% ȫ���Ӳ�
    struct('type','O5','n_outputs',2)% �����
    };

opts.numepochs=250;% numepochs��������
opts.alpha=0.5;  % alphaѧϰ��
rng('default');
% �ָ�matlab����ʱĬ�ϵ�ȫ�������
% ��matlab����ʱ������һ��Ĭ�ϵ�����������������ܶ�0��1֮���α�����
% ȫ���������rand�Ⱥ������������������Դ�ڴ�
% ��matlab�����ڼ䣬�κηֲ���������鶼�Ǹ�ȫ��������е����ݣ���ȻҲ��ʹ�����������������
cnn=cnnsetup(cnn,train_x,train_y);
disp('��ʼѵ��CNN')
[cnn,loss]=cnntrain(cnn,train_x,train_y,test_x,test_y,opts);



function [train_data, train_labels, test_data, test_labels] = readDATA()
% ����������Ϊ��
% ��ȡedf���ݼ���ֵ

% �������漰�Ĳ���Ϊ: 
% train_data -> ѵ������
% train_labels -> ѵ�����ݵı�ǩ
% test_data -> ��������
% test_labels -> �������ݵı�ǩ


%%��ȡѵ������
load edf;

imagesNo = 40;
for i = 1:imagesNo
    eeg_sample = eval(strcat('edf1',num2str(i)));
    eeg_sample = eeg_sample / max(eeg_sample(:));
    train_data{i} = eeg_sample;
end

%% ��ȡѵ�����ݱ�ǩ

y1=[2 0 1 0 1 0 2 0 2 0 1 0 2 0 1 0 2 0 1 0 1 0 2 0 1 0 2 0 1 0 2 0 1 0 2 0 2 0 1 0];
for j = 1:imagesNo
   train_labels{j} = y1(j);
end

%% ��ȡ��������
imagesNo = 18;
for i = 1:imagesNo
    eeg = eval(strcat('edf2',num2str(i)));  
    eeg = eeg / max(eeg(:));
    test_data{i} = eeg;
end


%% ��ȡ�������ݱ�ǩ
y2=[1 0 2 0 1 0 2 0 1 1 0 2 0 2 0 1 0 1];
for j = 1:imagesNo
   test_labels{j} = y2(j);
end

disp('EDF���ݳɹ���ȡ');

end



function [train_x, train_y, test_x, test_y] = transformDATA()
% ����������Ϊ��
% ��edf����ֵ��������cell��ʽת��Ϊ�������ݸ�ʽ
% ����������һ�������ݴ���

% �������漰�Ĳ���Ϊ: 
% train_x -> ѵ������
% train_y -> ѵ�����ݱ�ǩ
% test_x -> ��������
% test_y -> �������ݱ�ǩ

[train_data, train_labels,test_data,test_labels] = readDATA();% �����ݼ�
sizeTrain = size(train_data,2);% train_data������
sizeTest = size(test_data,2);% test_data������

% ת��ͼ������Ϊ480x64xsize�ĸ�ʽ
for i = 1:sizeTrain
    
    train_x(:,:,i)=train_data{i};
    train_yy(i)=train_labels{i};
    
end

for j = 1:sizeTest
    
    test_x(:,:,j)=test_data{j};
    test_yy(j)=test_labels{j};
    
end

% ����ת��label����
% eg��label����Ϊ0�����е�1������Ϊ1���������־�Ϊ0
% �Դ�����

train_y = zeros(3,sizeTrain);
test_y = zeros(3,sizeTest);

for i = 1:sizeTrain
    
    train_y(train_yy(i)+1,i) = 1;
         
end

for i = 1:sizeTest
    
    test_y(test_yy(i)+1,i) = 1;
    
end

disp('EDF���ݳɹ�ת��');

end



function X=sigm(P)

% 1.sigm����
% ���ܣ�һ�����㹫ʽ

X=1./(1+exp(-P));
end


function y=tanh(x)
% tanh����
a=1.7159;
b=2/3;
y=a*(exp(b*x)-exp(-1*b*x))./(exp(b*x)+exp(-1*b*x));
end



function X=flipall(X)

% 2.flipall����
% ���ܣ���ÿһ��ά�ȵ����ݾ���ת

for i=1:ndims(X)% ndims -> X��ά��
    X=flip(X,i);
    % ���A�Ǿ�����flip��A��1����תÿһ���е�Ԫ�أ���flip��A��2����תÿһ���е�Ԫ��
end
end


function out = tran1(ini)  %48*1*size--471*1*size
s=size(ini);
th=s(3);
out=zeros(471,1,th);
for i=1:1:th
    q=1;
    mid=ini(:,:,i); %mid 48*1
    for j=1:1:471
        if(rem(j-1,10)==0)
            out(j,1,i)=mid(q,1);
            q=q+1;
        end
    end
end
end


function out = tran2(ini)  %471*1*size--489*1*size
s=size(ini);
th=s(3);
out=zeros(489,1,th);
q=1;
for i=1:1:th
    out(10:480,:,i)=ini(:,:,i); % 471*1   
end
end



function net=cnnsetup(net,x,y)

    % ����������Ϊ��
    % ��ʼ��CNN

    % �������漰�Ĳ���Ϊ: 
    % ���룺net -> ��ʼ�趨�ľ�����������
    % x -> ѵ�����ݣ�y -> ѵ�����ݱ�ǩ
    % �����net -> ��ʼ��Ȩ�غ�ƫ�ú�ľ��������

    inputmaps=1;  % ��������ͼ����
    mapsize=size(squeeze(x(:,:,1))); % ��ȡѵ�����ݵĴ�С  

    % squeeze����ȥ��x��ֻ��һ����ά�ȣ�����x(:,:,1)��Ϊx(:,:)
    % size�������ؾ����С����mapsize��x(:,:)��������������Ϊһ����������

    % ����ͨ������net����ṹ������㹹��CNN����
    for l=1:numel(net.layers)%layer  ���ز���


        if strcmp(net.layers{l}.type,'C2')% �������Ǿ����  

            mapsize=[mapsize(1) (mapsize(2)-net.layers{l}.kernelsize)/net.layers{l}.stride+1];
            fan_out=net.layers{l}.outputmaps*net.layers{l}.kernelsize;

            % outputmaps��ʾ����˵ĸ���,fan_out��ʾ�������Ҫ���ܲ�������
            for j=1:net.layers{l}.outputmaps % ����ÿ�������
                fan_in=inputmaps*net.layers{l}.kernelsize; % ��������ͼƬÿ���������Ҫ�Ĳ�������

                for i=1:inputmaps % Ϊÿ������ͼ��ÿ������������ʼ��Ȩֵ��ƫ��
                    % ÿ������˵�Ȩֵ��һ��1*kernelsize�ľ���
                    % rand(m,n)�ǲ���m��n�� 0-1֮�����ȡֵ����ֵ�ľ����ټ�ȥ0.5���൱�ڲ���-0.5��0.5֮��������  
                    % �� *2 �ͷŴ� [-1, 1] 
                    % �������ǽ������ÿ��Ԫ�س�ʼ��Ϊ[-sqrt(6 / (fan_in + fan_out)), sqrt(6 / (fan_in + fan_out))]  
                    net.layers{l}.k{i}{j}=(rand(1,net.layers{l}.kernelsize)-0.5)*2*sqrt(6/(fan_in+fan_out));
                end
                net.layers{l}.b{j}=0;% ��ʼ��ÿ������˵�ƫ��
            end
            inputmaps=net.layers{l}.outputmaps*inputmaps; 
            %������������map�����������뵽��һ�������map����        
        end

        if strcmp(net.layers{l}.type,'C3')% �������Ǿ��+�������� 

            mapsize=[(mapsize(1)-net.layers{l}.kernelsize)/net.layers{l}.stride+1 mapsize(2)];
            fan_out=net.layers{l}.outputmaps*net.layers{l}.kernelsize;

            % outputmaps��ʾ����˵ĸ���,fan_out��ʾ�������Ҫ���ܲ�������
            for j=1:net.layers{l}.outputmaps % ����ÿ�������
                fan_in=inputmaps*net.layers{l}.kernelsize; % ������������mapÿ���������Ҫ�Ĳ�������

                for i=1:inputmaps % inputmapsΪÿ������map��ÿ������������ʼ��Ȩ�غ�ƫ��
                    % ÿ������˵�Ȩֵ��һ��kernelsize*1�ľ���
                    % rand(n)�ǲ���n��n�� 0-1֮�����ȡֵ����ֵ�ľ����ټ�ȥ0.5���൱�ڲ���-0.5��0.5֮��������  
                    % �� *2 �ͷŴ� [-1, 1] 
                    % �������ǽ������ÿ��Ԫ�س�ʼ��Ϊ[-sqrt(6 / (fan_in + fan_out)), sqrt(6 / (fan_in + fan_out))]  
                    net.layers{l}.k{i}{j}=(rand(net.layers{l}.kernelsize,1)-0.5)*2*sqrt(6/(fan_in+fan_out));
                end      
                 net.layers{l}.b{j}=0;% ��ʼ��ÿ������˵�ƫ��
            end
            inputmaps=net.layers{l}.outputmaps*inputmaps;
            %������������map�����������뵽��һ�������map���� 

        end

        if strcmp(net.layers{l}.type,'F4')% ��������ȫ���Ӳ� 
            % fvnum ��ȫ���Ӳ��ǰ��һ�����Ԫ����
            % ��һ�����һ���Ǿ������+��������Ĳ㣬������inputmaps������map
            % ÿ������map�Ĵ�С��mapsize
            % ���ԣ��ò����Ԫ������ inputmaps * ��ÿ������map�Ĵ�С��
            % ������ mapsize = [����map������ ����map������]������prod���������map����*��
            fvnum=prod(mapsize)* inputmaps;
            net.layers{l}.W=(rand(net.layers{l}.n_hidden,fvnum)-0.5)*2*sqrt(6/(net.layers{l}.n_hidden+fvnum));
            net.layers{l}.b=zeros(net.layers{l}.n_hidden,1)
        end

        if strcmp(net.layers{l}.type,'O5')% ������������� 
            % onum �Ǳ�ǩ�ĸ�����Ҳ�����������Ԫ�ĸ�������Ҫ�ֶ��ٸ��࣬��Ȼ���ж��ٸ������Ԫ
            onum=size(y,1);

            net.layers{l}.W=(rand(onum,net.layers{l-1}.n_hidden)-0.5)*2*sqrt(6/(onum+net.layers{l-1}.n_hidden));
            net.layers{l}.b=zeros(onum,1);
            % W �����ǰһ������������ӵ�Ȩֵ��������֮����ȫ���ӵ�
            % b �������ÿ����Ԫ��Ӧ�Ļ�biases
        end

    end
end

       

function [net,L]=cnntrain(net,x,y,test_x,test_y,opts)

% ����������Ϊ��
% ͨ�����������ѵ������

% �������漰�Ĳ���Ϊ: 
% ���룺x -> ѵ�����ݣ�y -> ѵ�����ݱ�ǩ test_x -> �������ݣ�test_y -> �������ݱ�ǩ
% net -> ѵ��ǰ�ľ�������磻opts -> �����������ز���
% �����net -> ѵ����ľ�������磻L -> ����

% numepochs -> ��������
L=zeros(opts.numepochs,1); % ��СΪ��������
n=1;

for i=1:opts.numepochs % ����ѭ��
    
    tic; % ��¼��ǰʱ��
    
    net=cnnff(net,x);% ʹ�õ�ǰ�����������ѵ��
    net=cnnbp(net,y);% bp�㷨ѵ��������
    net=cnngrads(net,opts);% Ȩֵ����
    
    L(n)=net.loss; % ����
    n=n+1;
        
    
    t=toc;% ��¼�������ʱ��
    
    str_perf=sprintf('; ����ѵ������ error= %f',net.loss);
    disp(['CNN train:epoch ' num2str(i) '/' num2str(opts.numepochs) '.Took' num2str(t) ' second''.' str_perf]);
    
    accuracy=cnntest(net,test_x,test_y);
    disp(['����׼ȷ�ʣ�' num2str(accuracy*100),'%'])
    acc(i)=accuracy;
end
i=1:250;
plot(i,acc(i));
xlabel('epochs');
ylabel('accuracy');
axis([0,250,0.4,1]);
hold on;
end



function net =cnnff(net,x)

% �������Ĺ���Ϊ��ʹ�õ�ǰ��������������ѵ�����ݽ���Ԥ��
% �������漰�Ĳ���Ϊ��
% ���룺net -> ��ѵ���������磻x -> ѵ�����ݾ���
% �����net -> ѵ���õ�������

n=numel(net.layers);% ����
net.layers{1}.a{1}=x;% ����ĵ�һ��������룬���������������˶��ѵ������
inputmaps=1;% �����ֻ��һ������map��Ҳ����ԭʼ����������

for l=2:n
    
    % ÿ��ѭ��
    if strcmp(net.layers{l}.type,'C2')
        % �����ǰ�Ǿ����    
        k=1;
        for j=1:net.layers{l}.outputmaps
            for i=1:inputmaps
                % ��ÿһ������map����Ҫ��outputmaps����ͬ�ľ����ȥ���ͼ��
                z=zeros(size(net.layers{l-1}.a{1})-[0 net.layers{l}.kernelsize-1 0]);
                % �������ʽ����һ���������Ϊ����map
                % ������һ���ÿһ������map������������map�Ĵ�С�ǣ�������map�� - ����˵Ŀ�+ 1��* ��������map�� - ����˸�)/���� + 1��
                % ����ÿ�㶼������������map�����Ӧ�������򱣴���ÿ��map�ĵ���ά������Z��
                
                % ��ÿ�����������map
                % ����һ���ÿһ������map��Ҳ������������map����ò�ľ���˽��о��
                % ���϶�Ӧλ�õĻ�b��Ȼ������sigmoid�����������map��ÿ��λ�õļ���ֵ����Ϊ�ò��������map
                z=z+convn(net.layers{l-1}.a{i},net.layers{l}.k{i}{j},'valid');
                net.layers{l}.a{k}=tanh(z+net.layers{l}.b{j});% �ӻ������ϼ���ƫ��b��
                k=k+1;
            end
        end
        inputmaps=net.layers{l}.outputmaps; % ���µ�ǰ���map����
    end   
    
    
    if strcmp(net.layers{l}.type,'C3')% �����ǰ���Ǿ��+��������
        k=1;
        for j=1:net.layers{l}.outputmaps
            for i=1:inputmaps
                % ��ÿһ������map����Ҫ��outputmaps����ͬ�ľ����ȥ���ͼ��
                z=zeros([(size(net.layers{l-1}.a{1},1)-net.layers{l}.kernelsize)/net.layers{l}.stride+1 size(net.layers{l-1}.a{1},2) size(net.layers{l-1}.a{1},3)]);
                % �������ʽ����һ���������Ϊ����map
                % ������һ���ÿһ������map������������map�Ĵ�С�ǣ���������map�� - ����˵Ŀ�/����+ 1��* ������map�� - ����˸� + 1��
                % ����ÿ�㶼������������map�����Ӧ�������򱣴���ÿ��map�ĵ���ά������Z��
            
                % ��ÿ�����������map
                % ����һ���ÿһ������map��Ҳ������������map����ò�ľ���˽��о��
                % ���о��
                % ���϶�Ӧλ�õĻ�b��Ȼ������sigmoid�����������map��ÿ��λ�õļ���ֵ����Ϊ�ò��������map
                c=convn(net.layers{l-1}.a{i},net.layers{l}.k{i}{j},'valid');
                z=z+c(1:10:end,1,1:size(net.layers{l-1}.a{1},3));
                net.layers{l}.a{k}=tanh(z+net.layers{l}.b{j});% �ӻ������ϼ���ƫ��b��
                k=k+1;
            end           
        end
        inputmaps=net.layers{l}.outputmaps*inputmaps; % ���µ�ǰ���map����        
    end

    if strcmp(net.layers{l}.type,'F4')% �����ǰ����ȫ���Ӳ�
        
        net.fv=[];% net.fvΪ������C3������map
        % ��C3��õ����������һ����������Ϊ������ȡ�õ�����������
        % ��ȡC3����ÿ������map�ĳߴ�
        % ��reshape������mapת��Ϊ��������ʽ
        % ʹ��sigmoid(W*X + b)����������Ԫ���ֵ
        for j=1:inputmaps% ���һ�������map�ĸ���
            sa=size(net.layers{l-1}.a{j}); % ��j������map�Ĵ�С
            net.fv=[net.fv;reshape(net.layers{l-1}.a{j},sa(1)*sa(2),sa(3))];
        end
	net.hidden_output = sigm(net.layers{l}.W*net.fv+net.layers{l}.b);
    end
        
    if strcmp(net.layers{l}.type,'O5')% �����ǰ���������
        % ʹ��sigmoid(W*X + b)���������������ֵ���ŵ�net��Աoutput��
        net.output=sigm(net.layers{l}.W*net.hidden_output+net.layers{l}.b);% ͨ��ȫ���Ӳ��ӳ��õ����������Ԥ�������
    end
end
end



function net =cnnbp(net,y)

    % �������Ĺ���Ϊ��
    % ͨ��bp�㷨ѵ�������纯��

    % �������漰���Ĳ���Ϊ��
    % ���룺net -> ��ѵ���������磻y -> ѵ�����ݱ�ǩ�����������õ������ݣ�
    % �����net -> ��bpѵ�����������


    n=numel(net.layers);
    net.error=y-net.output;% ʵ��������������֮������
    net.loss=0.5*sum(net.error(:).^2)/size(net.error,2);% ��ʧ���������þ���������Ϊ��ʧ����

    %�������ݶȵļ���
    net.d_output=-net.error .*(net.output .*(1-net.output));% �����������Ȼ��߲в�,(net.output .* (1 - net.output))���������ļ�����ĵ���
    net.layers{n}.dW=net.d_output*(net.hidden_output)'/size(net.d_output,2);
    net.layers{n}.db=mean(net.d_output,2);
    
    %ȫ���Ӳ���ݶȵļ���
    net.d_hidden_output=net.layers{n}.W'*net.d_output;% �в�򴫲���ǰһ��
    net.d_hidden_output=net.d_hidden_output.*(net.hidden_output .*(1-net.hidden_output));% net.hidden_output��ȫ���Ӳ���������Ϊ����������
    net.layers{n-1}.dW=net.d_hidden_output*(net.fv)'/size(net.d_hidden_output,2);
    net.layers{n-1}.db=mean(net.d_hidden_output,2);

    
    %���+����������ݶȵļ���
    sa=size(net.layers{n-2}.a{1}); % �������map�Ĵ�С
    fvnum=sa(1)*sa(2);
    net.layers{n-2}.d_output=(net.layers{n-1}.W)'*net.d_hidden_output;
    a=1.7159;
    b=2/3;
    
    
    for j=1:numel(net.layers{n-2}.a)% �ò������map�ĸ���
        net.layers{n-2}.d{j}=reshape(net.layers{n-2}.d_output(((j-1)*fvnum+1):j*fvnum,:),sa(1),sa(2),sa(3));
        net.layers{n-2}.d{j}=net.layers{n-2}.d{j}.*(a*a-net.layers{n-2}.a{j}.*net.layers{n-2}.a{j})*b./a;
         % net.layers{l}.d{j} ������ǵ�l��ĵ�j��map��������map��Ҳ����ÿ����Ԫ�ڵ��delta��ֵ
        net.layers{n-2}.d{j}=tran1(net.layers{n-2}.d{j});
    end

    k=1;
    for j=1:numel(net.layers{n-2}.outputmaps)
        for i=1:numel(net.layers{n-3}.a)
            % dk����������Ծ���˵ĵ���
            net.layers{n-2}.dk{i}{j}=convn(net.layers{n-3}.a{i},net.layers{n-2}.d{k},'valid')/size(net.layers{n-3}.a{i},3);
            k=k+1;
        end
        % db�������������bias���ĵ���
        net.layers{n-2}.db{j}=sum(net.layers{n-2}.d{(j-1)*numel(net.layers{n-3}.outputmaps)+1:j*numel(net.layers{n-3}.outputmaps)}(:))/size(net.layers{n-3}.a{i},3);
    end



    %�������ݶȵļ���   
    for j=1:numel(net.layers{n-2}.a)
        net.layers{n-2}.d{j}=tran2(net.layers{n-2}.d{j});
    end
    for j=1:numel(net.layers{n-2}.outputmaps)% �ò�����map�ĸ���
        for i=1:numel(net.layers{n-3}.a)
            net.layers{n-3}.d{j}=convn(net.layers{n-2}.d{j},flipall(net.layers{n-2}.k{i}{j}),'valid')/size(net.layers{n-2}.d{j},3).*(a*a-net.layers{n-3}.a{j}.*net.layers{n-3}.a{j})*b./a;
            % net.layers{l}.d{j} ������ǵ�l��ĵ�j��map��������map��Ҳ����ÿ����Ԫ�ڵ��delta��ֵ       
       end
    end
    k=1;
    for j=1:numel(net.layers{n-3}.outputmaps)
        for i=1:numel(net.layers{n-4}.a)
            % dk����������Ծ���˵ĵ���
            net.layers{n-3}.dk{i}{j}=convn(net.layers{n-4}.a{i},net.layers{n-3}.d{k},'valid')/size(net.layers{n-3}.a{i},3);
            k=k+1;
        end
        % db�������������bias���ĵ���
        net.layers{n-3}.db{j}=sum(net.layers{n-3}.d{j}(:))/size(net.layers{n-3}.a{i},3);        
    end




    end   

function net=cnngrads(net,opts)

    % �������Ĺ���Ϊ��
    % Ȩֵ���º���
    % �ȸ��¾����Ĳ������ٸ���ȫ���Ӳ����

    % �������漰���Ĳ���Ϊ��
    % ���룺net -> Ȩֵ�����µľ�������磻opts -> �����������ز���
    % �����net -> Ȩֵ���º�ľ��������

    for l=2:3
        for j=1:numel(net.layers{l}.outputmaps)
            for i=1:numel(net.layers{l-1}.a)
                % Ȩֵ���µĹ�ʽ��W_new = W_old + alpha * de/dW������Ȩֵ������
                net.layers{l}.k{i}{j}=net.layers{l}.k{i}{j}-opts.alpha*net.layers{l}.dk{i}{j};
            end
            net.layers{l}.b{j}=net.layers{l}.b{j}-opts.alpha*net.layers{l}.db{j};
        end
    end

    for l=4:5
        net.layers{l}.W=net.layers{l}.W-opts.alpha*net.layers{l}.dW;
        net.layers{l}.b=net.layers{l}.b-opts.alpha*net.layers{l}.db;
    end
end



function accuracy=cnntest(net,x,y)

% ����������Ϊ��
% �ò����������������Ǿ���ѵ����ľ��������

% �������漰�Ĳ���Ϊ: 
% ���룺net -> ѵ���õľ��������
% x -> ����ͼ�����ݣ�y -> ����ͼ�����ݱ�ǩ
% �����er -> ���Դ����ʣ�bad -> �����λ�� 

net=cnnff(net,x);
[~,h]=max(net.output);
[~,a]=max(y);% max(A) -> ���ؾ�����ÿһ�е����Ԫ��
bad = (h~=a);
error = 0;
for i = 1:size(bad,2)
    error = error+bad(i);
end
accuracy=1-error/size(y,2); % numbel(A) -> ���A����Ԫ��

end


