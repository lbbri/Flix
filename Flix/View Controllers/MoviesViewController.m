//
//  MoviesViewController.m
//  Flix
//
//  Created by admin on 6/25/20.
//  Copyright © 2020 admin. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;



@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //set data source and delegate to self
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //loading bar begin animating
    [self.activityIndicator startAnimating];
    
    //calls below function to reach out to API
    [self fetchMovies];
    
    //instaniate the object and allocate space for it
    self.refreshControl = [[UIRefreshControl alloc] init];
    //add the refreshcontrol to the tableview
    [self.tableView addSubview:self.refreshControl];
    //would keep spinning if this method was not called... it calls fetchMovies on self
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];

}

- (void)fetchMovies {
    
    //connect to API via URL
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    //Network Error Message (RUS 6)
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Load Movies" message:@"There seems to be an issue with the network connection." preferredStyle:(UIAlertControllerStyleAlert)];
    
    // create a try again action (the clickable button under on the error message)
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self fetchMovies];
    }];
    
    // add the try again action to the alert controller
    [alert addAction:tryAgainAction];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          //if there was an error when with getting the JSON
           if (error != nil) {
               //NSLog(@"%@", [error localizedDescription]);
               [self presentViewController:alert animated:YES completion:nil];
           }
           else {
               // TODO: Get the array of movies
               //load JSON data into dataDictionary
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               // TODO: Store the movies in a property to use elsewhere
               //populate movies array with each entry in dataDictionary
               self.movies = dataDictionary[@"results"];
               
               //loops through movies and prints off their titles
               /*for(NSDictionary *movie in self.movies){
                   NSLog(@"%@", movie[@"title"]);
               }*/
               
               // TODO: Reload your table view data
               //reload the data into the tableView
               [self.tableView reloadData];

           }
        
        //whether movies were loaded or not stop spinning
        [self.activityIndicator stopAnimating];
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}

//necessary for UITableViewSource implementation: gets # of rows, which in this case is however many movies it returned
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}
//necessary for UITableViewSource implementation: asks data source for a cell to insert
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //use the Movie cell I set up on the storyboard
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    //load movie at indexPath from movies array into movie dictionary, so that we can access it's id's
    NSDictionary *movie = self.movies[indexPath.row];
    
    
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    //concatenate the poster URL
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingFormat:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    
    //set to nil so that it does not have an old cell's image due to lagging
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath= [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}


@end
