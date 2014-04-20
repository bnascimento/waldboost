% WaldBoost algorithm
% WaldBoostClassfy            Classify the training sample
% searchBestWeakLearner       Get the best weak learner
% trainWaldBoostLearner       Waldboost training process
% testWaldBoostLearner        Waldboost testing process
% testWaldBoost               Generate data sample and call Waldboost to train and test
% WaldBoost                   WaldBoost train and test entry
% 
% Input:
% testX        test set
%              cntSamples * cntFeatures matrix
% Hypothesis   Strong learner constitue with Weak learner
% AlphaT       Weight for weak learner
% T            Number of weak learner
% thresh       (not used here)Waldboost thresh hold
% 
% �����
% testErrorRate         test error over only classified data
%testOverallErrorRate   test error over classified and unclassified data
% TPRate                True positive rate over test set
% FPRate                False positive rate over test set
% 
% 
function [testErrorRate,testOverallErrorRate,TPRate,FPRate]=testWaldBoostLearner(testX,testY,Hypothesis,AlphaT,varargin)
error(nargchk(4,6,nargin));          % input number check
iptcheckinput(testX,{'numeric'},{'2d','real','nonsparse'}, mfilename,'testX',1);
iptcheckinput(testY,{'logical','numeric'},{'row','nonempty','integer'},mfilename, 'testY',2);
iptcheckinput(Hypothesis,{'numeric'},{'2d','real','nonsparse'}, mfilename,'Hypothesis',3);
iptcheckinput(AlphaT,{'numeric'},{'row','nonempty','real'},mfilename, 'AlphaT',4);

cntHypothesis=size(Hypothesis,1);    % number of weak learner
if( nargin>4 )                       % set number of weak learner
    T = varargin{1};
    iptcheckinput(T,{'numeric'},{'row','nonempty','integer'},mfilename, 'T',5);
    if( cntHypothesis>T )            % check if invalid
        Hypothesis=Hypothesis(1:T,:);% use only T weak learners
        AlphaT=AlphaT(1:T);
    elseif( cntHypothesis<T )        % use all weak learners
        disp('too large input');
        T=cntHypothesis;
    end
else                                 % use all weak learners by default 
    T=cntHypothesis;
end
cntHypothesis=size(Hypothesis,1);    % number of weak learner

thresh=0.0;                          % threshold for Wald

nSamples=size(testX,1);         % size to test
testErrorRate=zeros(1,T);       % initialize test error
TPRate=zeros(1,T);              
FPRate=zeros(1,T);              

testOutput=zeros(1,nSamples);   
h=zeros(1,nSamples);
Decision=zeros(1,nSamples);             

for t=1:T 
  undecided_idx = find(Decision==0);
  [t size(undecided_idx)]             %debug info
  if(length(undecided_idx)<5)
    break;
  end
  samples = testX(undecided_idx,:);
  samples_Y = testY(undecided_idx);
  if(t ~= T)
    [testOutput]=WaldBoostTestClassify(samples,samples_Y,Hypothesis,AlphaT,t,0);
  else    %t = T: classify the rest undecided data
    [testOutput]=WaldBoostTestClassify(samples,samples_Y,Hypothesis,AlphaT,t,1);
  end
  idx = find(testOutput~=0);
  newdecided_idx = undecided_idx(idx);
  Decision(newdecided_idx) = testOutput(idx);
                                % get test error in round t           
  [errorRate,overallErrorRate,curTPRate,curFPRate]=calPredictErrorRate(testY,Decision);
  testErrorRate(t)=errorRate;
  testOverallErrorRate(t) = overallErrorRate;
  TPRate(t)=curTPRate;
  FPRate(t)=curFPRate;

end




