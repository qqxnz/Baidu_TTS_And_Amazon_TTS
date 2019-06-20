//
//  AmazonPolly.swift
//  getwell
//
//  Created by lv on 2018/12/29.
//  Copyright © 2018 JDHealth. All rights reserved.
//

import Foundation
//import AWSPolly

class AmazonPolly:NSObject{
    @objc static let shared = AmazonPolly()
    private var CognitoIdentityPoolId:String = "";
    override init() {
        super.init()
    }
    
    @objc func setCognitoIdentityPoolId(id:String){
        self.CognitoIdentityPoolId = id;
    }
    
    @objc func tts(text:String,completetion:@escaping (_ code:Int,_ data:Data?)->()){
        // Region of Amazon Polly.
        let AwsRegion = AWSRegionType.USEast1
        
        // Cognito pool ID. Pool needs to be unauthenticated pool with
        // Amazon Polly permissions.
        
        // Initialize the Amazon Cognito credentials provider.
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: AwsRegion, identityPoolId: self.CognitoIdentityPoolId)
        
        // Use the configuration as default
        AWSServiceManager.default().defaultServiceConfiguration = AWSServiceConfiguration.init(region: AwsRegion, credentialsProvider: credentialProvider)
        
        let input = AWSPollySynthesizeSpeechURLBuilderRequest()
        
        // Text to synthesize
        input.text = text
        
        // We expect the output in MP3 format
        input.outputFormat = AWSPollyOutputFormat.mp3
        
        // Choose the voice ID
        input.voiceId = AWSPollyVoiceId.kimberly
        
        // Create an task to synthesize speech using the given synthesis input
        let builder = AWSPollySynthesizeSpeechURLBuilder.default().getPreSignedURL(input)
        
        builder.continueOnSuccessWith(block: { (awsTask: AWSTask<NSURL>) -> Any? in
            let url = awsTask.result!
            let task = URLSession.shared.dataTask(with: url as URL, completionHandler: { (data, res, err) in
                if(data == nil){
                    completetion(404,nil);
                    return;
                }
                
                if(data!.count < 600){
                    completetion(-1,nil);
                    return;
                }
                
                completetion(200,data!);
                
            })
            
            task.resume()
            return nil
        })
        
    }
    
}
