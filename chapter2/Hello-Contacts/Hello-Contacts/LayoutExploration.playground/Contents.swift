import UIKit
import PlaygroundSupport

var constraintArray : [NSLayoutConstraint] = []

constraintArray += NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[uiview1]-10-|", options: [], metrics: nil, views: viewsDict)
constraintArray += NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[uiview2]-10-|", options: [], metrics: nil, views: viewsDict)
constraintArray += NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[uiview3]-10-|", options: [], metrics: nil, views: viewsDict)
constraintArray += NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[uiview1]-20-[uiview2]-30-[uiview3]-30-|", options: [], metrics: nil, views: viewsDict)
NSLayoutConstraint.activate(constraintArray)


func changeUIViewWidth() {

  //i don't know how to change width of uiview1 by animation
  UIView.animate(withDuration: 3){
    self.view.layoutIfNeeded()
  }
}
