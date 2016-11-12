//
//  MediaItemTableViewCell.swift
//  newsreader
//
//  Created by Bas on 10/29/16.
//  Copyright © 2016 Bas. All rights reserved.
//

import UIKit

class MediaItemTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var cellImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
