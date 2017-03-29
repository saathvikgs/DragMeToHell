//
//  View.swift
//  DragMeToHellSwift
//
//  Authors: Saathvik Shashidhar Gowrapura(SU ID - 450734672)
//  Course Number: CIS/CSE 651
//  Assignment 3
//
//  Created by Saathivk and Suhas on 3/23/16.
//  Copyright © 2016 Saathvik and Suhas. All rights reserved.
//
//  Base code given by Professor Robert Irwin
//

import UIKit

class MyView: UIView {

    var dw : CGFloat = 0;  var dh : CGFloat = 0    // width and height of cell
    var x : CGFloat = 0;   var y : CGFloat = 0     // touch point coordinates
    var row : Int = Int(arc4random_uniform(10));     var col : Int = 0       // selected cell in cell grid
    var flag : Bool = false
    var inMotion : Bool = false                    // true iff in process of dragging
    var randomwvalue = [Int]()                      // array to hold row values for random obstacles
    var randomhvalue = [Int]()                    // array to hold col values for random obstacles
    var len : Int = 18                             // number of obstacles
    var obsFlag = true                              // to create randomObstacles only once
    var imageRect:CGRect?;
    var devils : [UIImageView] = []                 // array of devils
    // stores the devils
    var img:UIImage?;
    override init(frame: CGRect) {
        print( "init(frame)" )
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        print( "init(coder)" )
        super.init(coder: aDecoder)
        initializearray()
       }
    
    func initializearray()                          // to set row and col position for random obstacles
    {
        var rwv : Int; var rhv : Int                    // to place obstacles randomly
        for _ in 0..<18 {
            rwv = Int(arc4random_uniform(10)); rhv = Int(arc4random_uniform(10))
            if((rwv == 9 && rhv == 9) || (rhv == 0 && rwv == row) ) {
                len--
                continue
            } else {
                randomwvalue.append(rwv)
                randomhvalue.append(rhv)
            }
        }
    }
    func drawObstacle()             // to create random obstacles and place them in devils array
    {
        for var j = 0; j < len; j++ {
            let tl2 = CGPointMake(CGFloat(randomwvalue[j])*self.dw, CGFloat(randomhvalue[j])*self.dh)
            let img2 : UIImage?
            img2 = UIImage(named: "vampire.png")
            let devil = UIImageView(image: img2)
            devils.append(devil)
            self.addSubview(devil)
            devil.frame = CGRectMake(tl2.x, tl2.y, self.dw, self.dh)
            performSelector( Selector("beginSpotAnimation:"), withObject: devil, afterDelay: 0.00 )
        }
    }
    
    override func drawRect(rect: CGRect) {
        print( "drawRect:" )
        
        let context = UIGraphicsGetCurrentContext()!  // obtain graphics context
        // CGContextScaleCTM( context, 0.5, 0.5 )  // shrink into upper left quadrant
        let bounds = self.bounds          // get view's location and size
        let w = CGRectGetWidth( bounds )   // w = width of view (in points)
        let h = CGRectGetHeight( bounds ) // h = height of view (in points)
        self.dw = w/10.0                      // dw = width of cell (in points)
        self.dh = h/10.0                      // dh = height of cell (in points)
        
        print( "view (width,height) = (\(w),\(h))" )
        print( "cell (width,height) = (\(self.dw),\(self.dh))" )
        
        // draw lines to form a 10x10 cell grid
        CGContextBeginPath( context )               // begin collecting drawing operations
        for i in 1..<10 {
            // draw horizontal grid line
            let iF = CGFloat(i)
            CGContextMoveToPoint( context, 0, iF*(self.dh) )
            CGContextAddLineToPoint( context, w, iF*self.dh )
        }
        for i in 1..<10 {
            // draw vertical grid line
            let iFlt = CGFloat(i)
            CGContextMoveToPoint( context, iFlt*self.dw, 0 )
            CGContextAddLineToPoint( context, iFlt*self.dw, h )
        }
        UIColor.grayColor().setStroke()                        // use gray as stroke color
        CGContextDrawPath( context, CGPathDrawingMode.Stroke ) // execute collected drawing ops
        
        // establish bounding box for image
        let tl = self.inMotion ? CGPointMake( self.x, self.y )
                               : CGPointMake( CGFloat(row)*self.dw, CGFloat(col)*self.dh )
        self.imageRect = CGRectMake(tl.x, tl.y, self.dw, self.dh)
        //img = UIImage(named: "angel.png")
        
        // to place random obstacles
        if(obsFlag){
            drawObstacle()
            obsFlag = false
        }

        if(self.collisionDetect() == true)
        {
            flag = true
        }
        else
        {
            flag = false
        }
        if(self.col == 9)
        {
            img = UIImage(named: "smiley.png")
            self.backgroundColor = UIColor.purpleColor()
        }
        
        else { if(self.collisionDetect() == true)
        {
          
            img = UIImage(named: "devil.png")
            self.backgroundColor = UIColor.redColor()
        }
        else {
            img = UIImage(named: "angel.png")
            self.backgroundColor = UIColor.cyanColor()
        }
        }
        
        img!.drawInRect(imageRect!)
    }
    
    func beginSpotAnimation(devil: UIImageView)                 // to begin animation of random obstacles
    {
        let X = devil.frame.origin.x + self.frame.origin.x
        let Y = devil.frame.origin.y + self.frame.origin.y
        let hdist = Double(0.5 * (Y-0.0)/10.0)
        UIView.animateWithDuration(hdist, delay: 0.0, options: [.CurveLinear,.CurveEaseIn, .AllowUserInteraction, .BeginFromCurrentState], animations: {devil.frame = CGRectMake(X, -self.dh, self.dw, self.dh)
            print("inside begin spot animation")
            if(self.col == 9)
            {
                self.img = UIImage(named: "smiley.png")
                self.backgroundColor = UIColor.purpleColor()
            }
            else {
            self.img = UIImage(named: "angel.png")
            self.backgroundColor = UIColor.cyanColor()
            }
            for (var i = self.devils.count - 1; i >= 0; --i)
            {
                let spot = self.devils[i]
                
    
                // We need to get the current "as-viewed" location of devil, but the frame
                // of devil is already set to its ending location. To get the
                // displayed frame, we need to access the Core Animation layer.
                let frame = spot.layer.presentationLayer()!.frame
                
               if(frame.intersects(self.imageRect!)){
                    
                    self.img = UIImage(named: "devil.png")
                    self.backgroundColor = UIColor.redColor()
                   //break
                    
                    
                }

            }
            
           }, completion: {(fin: Bool) in self.finishedAnimation("", finished:fin, context: devil)})
    }
    func finishedAnimation(animationId: String, finished: Bool, context: UIImageView)
    {
        let devil = context
        devil.frame = CGRectMake(devil.frame.origin.x + self.frame.origin.x, self.dh*10, self.dw, self.dh)
//        let Y = devil.frame.origin.y + self.frame.origin.y
//        let hdist = Double((Y-0.0)/10.0)
        UIView.animateWithDuration(Double(self.dh*0.5), delay: 0.0, options: [.CurveLinear,.CurveEaseIn, .AllowUserInteraction, .BeginFromCurrentState], animations: {() in devil.frame = CGRectMake(devil.frame.origin.x + self.frame.origin.x, -self.dh, self.dw, self.dh)
            
            print("inside finished animation")
            if(self.col == 9)
            {
                self.img = UIImage(named: "smiley.png")
                self.backgroundColor = UIColor.purpleColor()
            }
            else {
                self.img = UIImage(named: "angel.png")
                self.backgroundColor = UIColor.cyanColor()
            }
            for (var i = self.devils.count - 1; i >= 0; --i)
            {
                let spot = self.devils[i]
                
                
                // We need to get the current "as-viewed" location of devil, but the frame
                // of devil is already set to its ending location. To get the
                // displayed frame, we need to access the Core Animation layer.
                let frame = spot.layer.presentationLayer()!.frame
                
                if(frame.intersects(self.imageRect!)){
                    
                    self.img = UIImage(named: "devil.png")
                    self.backgroundColor = UIColor.redColor()
                   // break
                    
                    
               }

            
            }
            
            
           }, completion: {(fin: Bool) in self.finishedAnimation("", finished:fin, context: devil)})
    }
    
    func collisionDetect() -> Bool {                 // to detect collision between moving obstacle and angel
        for (var i = devils.count - 1; i >= 0; --i)
        {
            let spot = devils[i]
            
            if (spot.layer.presentationLayer() == nil) {
                return false
            }
            // We need to get the current "as-viewed" location of devil, but the frame
            // of devil is already set to its ending location. To get the
            // displayed frame, we need to access the Core Animation layer.
            let frame = spot.layer.presentationLayer()!.frame
            if(frame.intersects(self.imageRect!)){
            
                return true
            }
            
        }
        return false
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touchRow, touchCol : Int
        var xy : CGPoint
        //var flg : Int = 0
        print( "touchesBegan:withEvent:" )
        super.touchesBegan(touches, withEvent: event)
        for t in touches {
            xy = t.locationInView(self)
            self.x = xy.x;  self.y = xy.y
            touchRow = Int(self.x / self.dw);  touchCol = Int(self.y / self.dh)
            self.inMotion = (self.row == touchRow  &&  self.col == touchCol)
            print( "touch point (x,y) = (\(self.x),\(self.y))" )
            print( "  falls in cell (\(touchRow),\(touchCol))" )
            /*for var k = 0; k < len; k++ {
                if(self.row == randomwvalue[k] && self.col == randomhvalue[k]) {
                    //self.backgroundColor = UIColor.redColor()
                    flg = 1
                    break
                }
                else {
                    flg = 0//self.backgroundColor = UIColor.cyanColor()
                }
                self.backgroundColor = self.row == randomwvalue[k]  &&  self.col == randomhvalue[k] ? UIColor.redColor()
                    : UIColor.cyanColor()
            }*/
            if(self.col == 9)
            {
                self.backgroundColor = UIColor.purpleColor()
            }
            else { if(collisionDetect() == true) {
                self.backgroundColor = UIColor.redColor()
            } else {
                self.backgroundColor = UIColor.cyanColor()
                }
            }
        }
        
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touchRow, touchCol : Int
        //var flg :Int = 0
        var xy : CGPoint
        
        print( "touchesMoved:withEvent:" )
        super.touchesMoved(touches, withEvent: event)
        for t in touches {
            xy = t.locationInView(self)
            self.x = xy.x;  self.y = xy.y
            touchRow = Int(self.x / self.dw);  touchCol = Int(self.y / self.dh)
            print( "touch point (x,y) = (\(self.x),\(self.y))" )
            print( "  falls in cell (\(touchRow),\(touchCol))" )
            self.row = touchRow; self.col = touchCol
            /*for var k = 0; k < len; k++ {
                if(self.row == randomwvalue[k] && self.col == randomhvalue[k]) {
                    //self.backgroundColor = UIColor.redColor()
                    flg = 1
                    break
                }
                else {
                    flg = 0//self.backgroundColor = UIColor.cyanColor()
                }
                self.backgroundColor = self.row == randomwvalue[k]  &&  self.col == randomhvalue[k] ? UIColor.redColor()
                    : UIColor.cyanColor()
            }*/
            if(self.col == 9)
            {
                self.backgroundColor = UIColor.purpleColor()
            }
            else { if(collisionDetect() == true) {
                self.backgroundColor = UIColor.redColor()
            } else {
                self.backgroundColor = UIColor.cyanColor()
                }
            }
        }
        //self.backgroundColor = self.row == 9  &&  self.col == 9 ? UIColor.redColor()
          //  : UIColor.cyanColor()
        if self.inMotion {
            self.setNeedsDisplay()   // request view re-draw
        }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print( "touchesEnded:withEvent:" )
        super.touchesEnded(touches, withEvent: event)
        if self.inMotion {
            var touchRow : Int = 0;  var touchCol : Int = 0
            var xy : CGPoint
            //var flg :Int = 0; var flg2 : Int = 0;
            //var lastflag: Int = 0
            for t in touches {
                xy = t.locationInView(self)
                self.x = xy.x;  self.y = xy.y
                touchRow = Int(self.x / self.dw);  touchCol = Int(self.y / self.dh)
                print( "touch point (x,y) = (\(self.x),\(self.y))" )
                print( "  falls in cell (\(touchRow),\(touchCol))" )
            }
            self.inMotion = false
            self.row = touchRow;  self.col = touchCol
            //if self.row == 9  &&  self.col == 9 {
            //    flg2 = 0//self.backgroundColor = UIColor.redColor()
           // } else {
           //     flg2 = 0//self.backgroundColor = UIColor.purpleColor()
           // }
            self.backgroundColor = self.row == 9  &&  self.col == 9 ? UIColor.redColor()
                                                                    : UIColor.cyanColor()
           // to set purple color when angel reaches last row
            if( self.col == 9 && !flag) {
             //   lastflag = 1
            }
            /*for var k = 0; k < len; k++ {
                if(self.row == randomwvalue[k] && self.col == randomhvalue[k]) {
                    //self.backgroundColor = UIColor.redColor()
                    flg = 1
                    break
                }
                else {
                    flg = 0//self.backgroundColor = UIColor.cyanColor()
                }
                self.backgroundColor = self.row == randomwvalue[k]  &&  self.col == randomhvalue[k] ? UIColor.redColor()
                    : UIColor.cyanColor()
            }*/
            if(self.col == 9)
            {
                self.backgroundColor = UIColor.purpleColor()
            }
            else { if(collisionDetect() == true) {
                self.backgroundColor = UIColor.redColor()
            } else {
                self.backgroundColor = UIColor.cyanColor()
                }
            }
            
            //if(flg == 1 || flg2 == 1) {
             //   self.backgroundColor = UIColor.redColor()
           // } else { if(lastflag == 1) {
           // //    self.backgroundColor = UIColor.purpleColor()
           // } else {
            //    self.backgroundColor = UIColor.cyanColor()
                //}
            //}
            self.setNeedsDisplay()
        }
    }
    
    
//    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        print( "touchesCancelled:withEvent:" )
//        super.touchesCancelled(touches, withEvent: event)
//    }

}
