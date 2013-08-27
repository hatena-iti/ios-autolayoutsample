//
//  ViewController.m
//  AutoLayout
//
//  Created by sakura on 2013/08/21.
//  Copyright (c) 2013年 ITI. All rights reserved.
//

#import "ViewController.h"

typedef enum {
    ViewAlignmentLeft,
    ViewAlignmentRight
} ViewAlignment;

@interface ViewController () {
    ViewAlignment propertiesAlignment;

    UITextField *keyText; // key1のtextと連動
    UILabel *key1;
    
    UITextField *valueText; // value1のtextと連動
    UILabel *value1;

    NSDictionary *allViews; // Auto Layoutで管理されているview
    NSArray *propertiesConstraint; // 灰色のテーブルの横方向のConstraint
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 緑のテーブル部分関連
    // UITextFieldの内容を変更すると対応するUILabelのtextが変更される。
    // すると自動でレイアウトが適切に更新される。
    keyText = [[UITextField alloc] init];
    keyText.translatesAutoresizingMaskIntoConstraints = NO;
    keyText.placeholder = @"key1";
    keyText.text = @"key1";
    keyText.borderStyle = UITextBorderStyleRoundedRect;
    keyText.delegate = self;
    [self.view addSubview:keyText];
    
    valueText = [[UITextField alloc] init];
    valueText.translatesAutoresizingMaskIntoConstraints = NO;
    valueText.text = @"value";
    valueText.placeholder = @"placeholder";
    valueText.borderStyle = UITextBorderStyleRoundedRect;
    valueText.delegate = self;
    [self.view addSubview:valueText];
    
    // 緑のテーブル部分のLabel
    key1 = [self labelWithTitle:keyText.text color:[UIColor greenColor]];
    key1.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:key1];
    
    value1 = [self labelWithTitle:valueText.text color:[UIColor greenColor]];
    [self.view addSubview:value1];
    
    UILabel *key2 = [self labelWithTitle:@"key2" color:[UIColor greenColor]];
    key2.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:key2];
    
    UILabel *key3 = [self labelWithTitle:@"key3" color:[UIColor greenColor]];
    key3.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:key3];
    
    UILabel *value2 = [self labelWithTitle:@"value2" color:[UIColor greenColor]];
    [self.view addSubview:value2];
    
    UILabel *value3 = [self labelWithTitle:@"value3" color:[UIColor greenColor]];
    [self.view addSubview:value3];
    
    // NSDictionaryから表を作成するサンプル。
    UIView *properitesView = [self viewForProperties:@{@"short key":@"short", @"long key name":@"long value"}];
    properitesView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:properitesView];
    
    // アニメーション用ボタン。
    // 押すたびにproperitesViewが左⇔右に移動する。
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:@"Animation!" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // Auto Layout用のパラメータ
    allViews = NSDictionaryOfVariableBindings(keyText, valueText, key1, key2, key3, value1, value2, value3, properitesView, button);
    NSDictionary *metrics = @{@"margin": @3};
    
    // 固定的なレイアウト指定
    // アニメーション等で動的に変更されるものはupdateViewConstraintsで定義
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[keyText]-[valueText(==keyText)]-|" options:0 metrics:nil views:allViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[key1(==key2,==key3)]-[value1(==value2,==value3)]" options:0 metrics:nil views:allViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[key2]-[value2]" options:0 metrics:nil views:allViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[key3]-[value3]" options:0 metrics:nil views:allViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[button]" options:0 metrics:nil views:allViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[keyText]-[key1(==key2,==key3,==value1)]-margin-[key2]-margin-[key3]-[properitesView]-[button]"
                                                                      options:0 metrics:metrics views:allViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[valueText]-[value1(==value2,==value3)]-margin-[value2]-margin-[value3]-[properitesView]-[button]"
                                                                      options:0 metrics:metrics views:allViews]];
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    
    [self updatePropertiesConstraint];
}

#pragma mark -

- (NSString *)propertiesConstraintString {
    switch (propertiesAlignment) {
        case ViewAlignmentLeft: return @"|-[properitesView]";
        case ViewAlignmentRight: return @"[properitesView]-|";
        default: return @"";
    }
}

- (NSArray *)propertiesConstraints {
    return [NSLayoutConstraint constraintsWithVisualFormat:[self propertiesConstraintString] options:0 metrics:nil views:allViews];
}

- (void)toggleLayoutState {
    propertiesAlignment = (propertiesAlignment + 1) % 2;
    [self updateViewConstraints];
}

- (IBAction)didTapButton:(id)sender {
    [self toggleLayoutState];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)updatePropertiesConstraint {
    if (propertiesConstraint) {
        [self.view removeConstraints:propertiesConstraint];
    }
    propertiesConstraint = [self propertiesConstraints];
    [self.view addConstraints:propertiesConstraint];
}

#pragma mark - Factories

- (UIView *)sampleViewWithColor:(UIColor *)color {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.backgroundColor = color;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

- (UILabel *)labelWithTitle:(NSString *)title color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = title;
    label.backgroundColor = color;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (UILabel *)labelWithTitle:(NSString *)title {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = title;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor = [UIColor grayColor];
    return label;
}

- (UIView *)viewForProperties:(NSDictionary *)properties {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    NSDictionary *views = [self viewsForProperties:properties];
    for (UIView *label in [views allValues]) {
        [view addSubview:label];
    }
    [view addConstraints:[self constraintsForProperties:views]];
    [view invalidateIntrinsicContentSize];
    return view;
}

#pragma mark - Create table from Dictionary

- (NSDictionary *)viewsForProperties:(NSDictionary *)properties {
    __block int n = 0;
    NSMutableDictionary *views = [NSMutableDictionary dictionaryWithCapacity:[properties count] * 2];
    [properties enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL* stop){
        UILabel *keyLabel = [self labelWithTitle:key];
        keyLabel.textAlignment = NSTextAlignmentRight;
        [views setObject:keyLabel forKey:[NSString stringWithFormat:@"key%d", n]];
        [views setObject:[self labelWithTitle:value] forKey:[NSString stringWithFormat:@"value%d", n]];
        n++;
    }];
    return views;
}

- (NSArray *)constraintsForProperties:(NSDictionary *)properites {
    NSMutableArray *constraints = [NSMutableArray array];
    for (NSString *string in [self constraintStringsForCount:[properites count] / 2]) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:string options:0 metrics:nil views:properites]];
    }
    return constraints;
}

- (NSArray *)constraintStringsForCount:(NSUInteger)count {
    return [[self horizontalConstraintsForCount:count] arrayByAddingObjectsFromArray:[self virticalConstraintsForCount:count]];
}

- (NSArray *)horizontalConstraintsForCount:(NSUInteger)count {
    NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [constraints addObject:[NSString stringWithFormat:@"|-[key%d]-[value%d(==key%d)]-|", i, i, i]];
    }
    return constraints;
}

- (NSArray *)virticalConstraintsForCount:(NSUInteger)count {
    return @[[self virticalConstraintForName:@"key" count:count], [self virticalConstraintForName:@"value" count:count]];
}

- (NSString *)virticalConstraintForName:(NSString *)name count:(NSUInteger)count {
    NSMutableString *constraint = [NSMutableString stringWithString:@"V:|"];
    for (int i = 0; i < count; i++) {
        [constraint appendFormat:@"-[%@%d]", name, i];
    }
    [constraint appendFormat:@"-|"];
    
    return constraint;
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == keyText) {
        key1.text = keyText.text;
    } else if (textField == valueText) {
        value1.text = valueText.text;
    }
}

@end
